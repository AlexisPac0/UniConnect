import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/app_session.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';
import 'package:uniconnect/features/profile/domain/failures/profile_failures.dart';
import 'package:uniconnect/features/profile/domain/usecases/get_user_profile.dart';
import 'package:uniconnect/features/profile/presentation/session/session_controller.dart';

import '../../fixtures.dart';

class MockWatchAuthState extends Mock implements WatchAuthState {}

class MockGetUserProfile extends Mock implements GetUserProfile {}

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
  late AppSession session;
  late SessionController controller;

  setUp(() {
    auth = StreamController<AuthUser?>.broadcast();
    watchAuthState = MockWatchAuthState();
    getUserProfile = MockGetUserProfile();
    session = AppSession();
    when(() => watchAuthState()).thenAnswer((_) => auth.stream);
    controller = SessionController(
      watchAuthState: watchAuthState,
      getUserProfile: getUserProfile,
      session: session,
    );
  });

  tearDown(() async {
    await controller.dispose();
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

    await controller.dispose();

    expect(auth.hasListener, isFalse);
    await emit(null);
    expect(session.state, const SessionLoading());
  });

  test('dispose ignores a profile still loading', () async {
    final profile = Completer<Result<UserProfile>>();
    when(() => getUserProfile(tUserId)).thenAnswer((_) => profile.future);
    controller.start();
    await emit(tAuthUser);

    await controller.dispose();
    profile.complete(const Success(tStudentProfile));
    await flush();

    expect(session.state, const SessionLoading());
  });
}
