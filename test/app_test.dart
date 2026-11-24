import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/app.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/core/session/app_session.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/widgets/splash_page.dart';
import 'package:uniconnect/features/auth/data/datasources/auth_data_source.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/presentation/pages/login_page.dart';
import 'package:uniconnect/features/profile/data/datasources/user_profile_data_source.dart';
import 'package:uniconnect/features/profile/data/models/user_profile_model.dart';
import 'package:uniconnect/features/profile/domain/failures/profile_failures.dart';
import 'package:uniconnect/features/profile/presentation/session/session_controller.dart';

/// Stands for Firebase Auth: like the real SDK, [authStateChanges] first
/// emits the persisted user, and [signOut] then emits `null`.
class FakeAuthDataSource implements AuthDataSource {
  /// User kept signed in from a previous launch of the app.
  AuthUser? persistedUser;

  int signOutCalls = 0;

  final StreamController<AuthUser?> _changes =
      StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> authStateChanges() {
    late final StreamController<AuthUser?> controller;
    StreamSubscription<AuthUser?>? changes;
    controller = StreamController<AuthUser?>(
      onListen: () {
        controller.add(persistedUser);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    persistedUser = null;
    _changes.add(null);
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }
}

/// Stands for Firestore: the `users/{id}` documents.
class FakeUserProfileDataSource implements UserProfileDataSource {
  static const profiles = {
    'student-1': UserProfileModel(
      id: 'student-1',
      email: 'jane.doe@university.hr',
      displayName: 'Jane Doe',
      role: UserRole.student,
    ),
  };

  @override
  Future<UserProfileModel?> getUserProfile(String userId) async {
    return profiles[userId];
  }
}

/// End-to-end smoke tests with the real dependency graph.
///
/// Firebase is never touched: the Firebase data sources are replaced by
/// fakes. Most tests set the [AppSession] directly, as the
/// `SessionController` would do; the "session" group runs the real
/// controller against the fakes.
void main() {
  late FakeAuthDataSource auth;

  setUp(() {
    configureDependencies();
    auth = FakeAuthDataSource();
    getIt
      ..unregister<AuthDataSource>()
      ..registerLazySingleton<AuthDataSource>(() => auth)
      ..unregister<UserProfileDataSource>()
      ..registerLazySingleton<UserProfileDataSource>(
        FakeUserProfileDataSource.new,
      );
  });
  tearDown(() => getIt.reset());

  AppSession session() => getIt<AppSession>();

  void signInAs(UserRole role) {
    session().setSignedIn(
      userId: 'user-1',
      role: role,
      displayName: 'Test user',
    );
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(UniConnectApp(router: getIt<GoRouter>()));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the splash screen while the session is loading', (
    tester,
  ) async {
    await tester.pumpWidget(UniConnectApp(router: getIt<GoRouter>()));
    await tester.pump();

    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('shows the login screen when signed out', (tester) async {
    session().setSignedOut();
    await pumpApp(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('a signed-in student starts on the student home', (tester) async {
    signInAs(UserRole.student);
    await pumpApp(tester);

    expect(find.text('Student space'), findsOneWidget);
    expect(find.text('Your timetable'), findsOneWidget);
  });

  testWidgets('opens the timetable from the home and goes back', (
    tester,
  ) async {
    signInAs(UserRole.student);
    await pumpApp(tester);

    await tester.tap(find.text('Your timetable'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Timetable'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Student space'), findsOneWidget);
  });

  testWidgets('leaves the splash screen once the profile is loaded', (
    tester,
  ) async {
    await tester.pumpWidget(UniConnectApp(router: getIt<GoRouter>()));
    await tester.pump();

    signInAs(UserRole.professor);
    await tester.pumpAndSettle();

    expect(find.text('Professor space'), findsOneWidget);
    expect(find.text('Start an attendance session'), findsOneWidget);
  });

  testWidgets('switching the session role shows the matching home', (
    tester,
  ) async {
    signInAs(UserRole.student);
    await pumpApp(tester);

    signInAs(UserRole.professor);
    await tester.pumpAndSettle();

    expect(find.text('Professor space'), findsOneWidget);
  });

  group('session (real SessionController, fake Firebase)', () {
    const student = AuthUser(id: 'student-1', email: 'jane.doe@university.hr');

    Future<void> launchApp(WidgetTester tester) async {
      getIt<SessionController>().start();
      await pumpApp(tester);
    }

    Future<void> logOut(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
      await tester.pumpAndSettle();
    }

    testWidgets('restores the session of a user still signed in', (
      tester,
    ) async {
      auth.persistedUser = student;

      await launchApp(tester);

      expect(find.text('Student space'), findsOneWidget);
      expect(
        session().state,
        const SessionSignedIn(
          userId: 'student-1',
          role: UserRole.student,
          displayName: 'Jane Doe',
        ),
      );
    });

    testWidgets('opens the login screen when nobody is signed in', (
      tester,
    ) async {
      await launchApp(tester);

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('logging out clears the session and opens the login screen', (
      tester,
    ) async {
      auth.persistedUser = student;
      await launchApp(tester);

      await logOut(tester);

      expect(auth.signOutCalls, 1);
      expect(session().state, const SessionSignedOut());
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Student space'), findsNothing);
    });

    testWidgets('cancelling the log out keeps the session', (tester) async {
      auth.persistedUser = student;
      await launchApp(tester);

      await tester.tap(find.byTooltip('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(auth.signOutCalls, 0);
      expect(find.text('Student space'), findsOneWidget);
    });

    testWidgets('a user without profile is signed out with the reason', (
      tester,
    ) async {
      auth.persistedUser = const AuthUser(
        id: 'no-profile',
        email: 'ghost@university.hr',
      );

      await launchApp(tester);

      expect(auth.signOutCalls, 1);
      expect(session().errorMessage, const ProfileNotFoundFailure().message);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text(const ProfileNotFoundFailure().message), findsOneWidget);
    });
  });
}
