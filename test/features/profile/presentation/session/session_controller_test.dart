import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/app_session.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_out.dart';
import 'package:uniconnect/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';
import 'package:uniconnect/features/profile/domain/failures/profile_failures.dart';
import 'package:uniconnect/features/profile/domain/usecases/get_user_profile.dart';
import 'package:uniconnect/features/profile/presentation/session/session_controller.dart';

import '../../fixtures.dart';

class MockWatchAuthState extends Mock implements WatchAuthState {}

class MockGetUserProfile extends Mock implements GetUserProfile {}

class MockSignOut extends Mock implements SignOut {}

void main() {
  const tAuthUser = AuthUser(id: tUserId, email: 'jane.doe@university.hr');
  const tOtherAuthUser = AuthUser(id: 'user-456', email: 'john@university.hr');
  const tOtherProfile = UserProfile(
    id: 'user-456',
    email: 'john@university.hr',
    displayName: 'John Smith',
    role: UserRole.professor,
  );
  const tSignedIn = SessionSignedIn(
    userId: tUserId,
    role: UserRole.student,
    displayName: 'Jane Doe',
  );

  late StreamController<AuthUser?> auth;
  late MockWatchAuthState watchAuthState;
  late MockGetUserProfile getUserProfile;
  late MockSignOut signOut;
  late AppSession session;
  late SessionController controller;

  setUp(() {
    auth = StreamController<AuthUser?>.broadcast();
    watchAuthState = MockWatchAuthState();
    getUserProfile = MockGetUserProfile();
    signOut = MockSignOut();
    session = AppSession();
    when(() => watchAuthState()).thenAnswer((_) => auth.stream);
    when(
      () => signOut(const NoParams()),
    ).thenAnswer((_) async => const Success<void>(null));
    controller = SessionController(
      watchAuthState: watchAuthState,
      getUserProfile: getUserProfile,
      signOut: signOut,
      session: session,
    );
  });

  tearDown(() async {
    controller.dispose();
    await auth.close();
    session.dispose();
  });

  /// Lets the stream deliver its events and the pending futures complete.
  Future<void> flush() => Future<void>.delayed(Duration.zero);

  void stubProfile(String userId, Result<UserProfile> result) {
    when(() => getUserProfile(userId)).thenAnswer((_) async => result);
  }

  Future<void> emit(AuthUser? user) async {
    auth.add(user);
    await flush();
  }

  test('does nothing before start', () async {
    await emit(tAuthUser);

    expect(session.state, const SessionLoading());
    verifyNever(() => watchAuthState());
  });

  test('nobody signed in: signedOut', () async {
    controller.start();

    await emit(null);

    expect(session.state, const SessionSignedOut());
    verifyZeroInteractions(getUserProfile);
    verifyZeroInteractions(signOut);
  });

  test('signed in: loading while the profile loads', () async {
    final profile = Completer<Result<UserProfile>>();
    when(() => getUserProfile(tUserId)).thenAnswer((_) => profile.future);
    session.setSignedOut(); // Not loading, to see the controller set it.
    controller.start();

    await emit(tAuthUser);

    expect(session.state, const SessionLoading());

    profile.complete(const Success(tStudentProfile));
    await flush();
    expect(session.state, tSignedIn);
  });

  test('profile loaded: signedIn with the role of the profile', () async {
    stubProfile(tUserId, const Success(tStudentProfile));
    controller.start();

    await emit(tAuthUser);

    expect(session.state, tSignedIn);
    verify(() => getUserProfile(tUserId)).called(1);
    verifyZeroInteractions(signOut);
  });

  for (final failure in const [
    ProfileNotFoundFailure(),
    InvalidRoleFailure(),
  ]) {
    test(
      '${failure.runtimeType}: signedOut with the failure message',
      () async {
        stubProfile(tUserId, Failure(failure));
        controller.start();

        await emit(tAuthUser);

        expect(session.state, SessionSignedOut(errorMessage: failure.message));
      },
    );
  }

  group('profile failure: forced sign-out', () {
    const failure = InvalidRoleFailure();

    setUp(() => stubProfile(tUserId, const Failure(failure)));

    test('signs out of Firebase after the session is signed out', () async {
      SessionState? stateWhenSigningOut;
      when(() => signOut(const NoParams())).thenAnswer((_) async {
        stateWhenSigningOut = session.state;
        return const Success<void>(null);
      });
      controller.start();

      await emit(tAuthUser);

      verify(() => signOut(const NoParams())).called(1);
      expect(
        stateWhenSigningOut,
        SessionSignedOut(errorMessage: failure.message),
      );
    });

    test('the message survives the null emitted by Firebase after', () async {
      // Like Firebase: signing out emits `null` on the auth stream.
      when(() => signOut(const NoParams())).thenAnswer((_) async {
        auth.add(null);
        return const Success<void>(null);
      });
      controller.start();

      await emit(tAuthUser);
      await flush();

      expect(session.state, SessionSignedOut(errorMessage: failure.message));
      verify(() => signOut(const NoParams())).called(1);
    });

    test('a failing SignOut keeps the session signed out, once', () async {
      when(() => signOut(const NoParams())).thenAnswer(
        (_) async => const Failure<void>(
          UnexpectedFailure(message: 'Could not log you out.'),
        ),
      );
      controller.start();

      await emit(tAuthUser);
      await flush();

      expect(session.state, SessionSignedOut(errorMessage: failure.message));
      verify(() => signOut(const NoParams())).called(1);
      verify(() => getUserProfile(tUserId)).called(1);
    });

    test('no sign-out for the outdated failure of a replaced user', () async {
      final firstProfile = Completer<Result<UserProfile>>();
      when(
        () => getUserProfile(tUserId),
      ).thenAnswer((_) => firstProfile.future);
      stubProfile('user-456', const Success(tOtherProfile));
      controller.start();

      await emit(tAuthUser);
      await emit(tOtherAuthUser);
      firstProfile.complete(const Failure(failure));
      await flush();

      expect(session.role, UserRole.professor);
      verifyZeroInteractions(signOut);
    });
  });

  group('session restored at startup', () {
    test(
      'a user already signed in is emitted on listen and signed in',
      () async {
        // Like Firebase Auth: the persisted user is the first event.
        when(() => watchAuthState()).thenAnswer((_) => Stream.value(tAuthUser));
        stubProfile(tUserId, const Success(tStudentProfile));
        final states = <SessionState>[session.state];
        session.addListener(() => states.add(session.state));

        controller.start();
        await flush();

        expect(states, [const SessionLoading(), tSignedIn]);
        verify(() => watchAuthState()).called(1);
        verify(() => getUserProfile(tUserId)).called(1);
        verifyZeroInteractions(signOut);
      },
    );

    test('stays on loading until the restored profile is loaded', () async {
      final profile = Completer<Result<UserProfile>>();
      when(() => watchAuthState()).thenAnswer((_) => Stream.value(tAuthUser));
      when(() => getUserProfile(tUserId)).thenAnswer((_) => profile.future);

      controller.start();
      await flush();

      expect(session.state, const SessionLoading());

      profile.complete(const Success(tStudentProfile));
      await flush();

      expect(session.state, tSignedIn);
    });

    test('nobody persisted: signed out without loading a profile', () async {
      when(() => watchAuthState()).thenAnswer((_) => Stream.value(null));

      controller.start();
      await flush();

      expect(session.state, const SessionSignedOut());
      verifyZeroInteractions(getUserProfile);
    });
  });

  test('a sign-out after a failure keeps the error message', () async {
    stubProfile(tUserId, const Failure(InvalidRoleFailure()));
    controller.start();
    await emit(tAuthUser);

    await emit(null);

    expect(
      session.state,
      SessionSignedOut(errorMessage: const InvalidRoleFailure().message),
    );
  });

  test('a new sign-in after a failure clears the error message', () async {
    stubProfile(tUserId, const Failure(InvalidRoleFailure()));
    stubProfile('user-456', const Success(tOtherProfile));
    controller.start();
    await emit(tAuthUser);

    await emit(tOtherAuthUser);

    expect(session.errorMessage, isNull);
    expect(session.role, UserRole.professor);
  });

  test('ignores the profile of a user replaced while loading', () async {
    final firstProfile = Completer<Result<UserProfile>>();
    when(() => getUserProfile(tUserId)).thenAnswer((_) => firstProfile.future);
    stubProfile('user-456', const Success(tOtherProfile));
    controller.start();

    await emit(tAuthUser);
    await emit(tOtherAuthUser);
    firstProfile.complete(const Success(tStudentProfile));
    await flush();

    expect(
      session.state,
      const SessionSignedIn(
        userId: 'user-456',
        role: UserRole.professor,
        displayName: 'John Smith',
      ),
    );
  });

  test('ignores the profile of a user signed out while loading', () async {
    final profile = Completer<Result<UserProfile>>();
    when(() => getUserProfile(tUserId)).thenAnswer((_) => profile.future);
    controller.start();

    await emit(tAuthUser);
    await emit(null);
    profile.complete(const Success(tStudentProfile));
    await flush();

    expect(session.state, const SessionSignedOut());
  });

  test('start twice subscribes only once', () async {
    controller
      ..start()
      ..start();

    verify(() => watchAuthState()).called(1);
  });

  test('dispose cancels the subscription', () async {
    controller.start();
    expect(auth.hasListener, isTrue);

    controller.dispose();

    expect(auth.hasListener, isFalse);
    await emit(null);
    expect(session.state, const SessionLoading());
  });

  test('dispose ignores a profile still loading', () async {
    final profile = Completer<Result<UserProfile>>();
    when(() => getUserProfile(tUserId)).thenAnswer((_) => profile.future);
    controller.start();
    await emit(tAuthUser);

    controller.dispose();
    profile.complete(const Success(tStudentProfile));
    await flush();

    expect(session.state, const SessionLoading());
  });
}
