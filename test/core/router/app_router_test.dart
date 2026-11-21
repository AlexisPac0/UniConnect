import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/core/router/app_router.dart';
import 'package:uniconnect/core/router/app_routes.dart';
import 'package:uniconnect/core/session/app_feature.dart';
import 'package:uniconnect/core/session/current_session.dart';
import 'package:uniconnect/core/session/role_access_policy.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/widgets/placeholder_page.dart';
import 'package:uniconnect/features/home/presentation/cubit/home_cubit.dart';
import 'package:uniconnect/features/home/presentation/pages/home_page.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  group('AppRoutes.featureFor', () {
    final features = {
      AppRoutes.timetable: AppFeature.timetable,
      AppRoutes.lectureDetailsPath('42'): AppFeature.timetable,
      AppRoutes.qrScan: AppFeature.attendanceCheckIn,
      AppRoutes.myAttendance: AppFeature.myAttendance,
      AppRoutes.attendanceSession: AppFeature.attendanceSession,
      AppRoutes.attendanceDashboard: AppFeature.attendanceDashboard,
      AppRoutes.courses: AppFeature.courseManagement,
      AppRoutes.courseMembersPath('MOB-101'): AppFeature.courseManagement,
      AppRoutes.settings: AppFeature.settings,
    };
    features.forEach((path, feature) {
      test('$path belongs to ${feature.name}', () {
        expect(AppRoutes.featureFor(path), feature);
      });
    });

    test('every feature is reachable through a route', () {
      expect(features.values.toSet(), AppFeature.values.toSet());
    });

    test('login, root, homes and unknown paths are not guarded', () {
      for (final path in [
        AppRoutes.login,
        AppRoutes.root,
        ...AppRoutes.homes,
        '/does-not-exist',
        '/timetables',
      ]) {
        expect(AppRoutes.featureFor(path), isNull, reason: path);
      }
    });
  });

  group('redirectForSession', () {
    test('signed out: every route goes to login', () {
      final session = CurrentSession(role: null);

      expect(redirectForSession(session, AppRoutes.root), AppRoutes.login);
      expect(
        redirectForSession(session, AppRoutes.studentHome),
        AppRoutes.login,
      );
      expect(redirectForSession(session, AppRoutes.timetable), AppRoutes.login);
      expect(redirectForSession(session, AppRoutes.login), isNull);
    });

    for (final role in UserRole.values) {
      group('signed in as ${role.name}', () {
        final session = CurrentSession(role: role);
        final home = AppRoutes.homeFor(role);

        test('login and root go to the role home', () {
          expect(redirectForSession(session, AppRoutes.login), home);
          expect(redirectForSession(session, AppRoutes.root), home);
        });

        test('the role home is not redirected', () {
          expect(redirectForSession(session, home), isNull);
        });

        test('the homes of the other roles go to the role home', () {
          for (final other in AppRoutes.homes.difference({home})) {
            expect(redirectForSession(session, other), home);
          }
        });

        test('shared screens are not redirected', () {
          expect(redirectForSession(session, AppRoutes.timetable), isNull);
          expect(redirectForSession(session, AppRoutes.settings), isNull);
        });

        test('only the screens of the role features are open', () {
          const policy = RoleAccessPolicy();
          for (final path in [
            AppRoutes.timetable,
            AppRoutes.lectureDetailsPath('42'),
            AppRoutes.qrScan,
            AppRoutes.myAttendance,
            AppRoutes.attendanceSession,
            AppRoutes.attendanceDashboard,
            AppRoutes.courses,
            AppRoutes.courseMembersPath('MOB-101'),
            AppRoutes.settings,
          ]) {
            final allowed = policy.canAccess(role, AppRoutes.featureFor(path)!);
            expect(
              redirectForSession(session, path),
              allowed ? isNull : home,
              reason: path,
            );
          }
        });
      });
    }

    test('a student is sent home from professor and admin screens', () {
      final session = CurrentSession();

      expect(
        redirectForSession(session, AppRoutes.attendanceSession),
        AppRoutes.studentHome,
      );
      expect(
        redirectForSession(session, AppRoutes.courseMembersPath('MOB-101')),
        AppRoutes.studentHome,
      );
    });

    test('a professor cannot manage courses or scan a QR code', () {
      final session = CurrentSession(role: UserRole.professor);

      expect(
        redirectForSession(session, AppRoutes.courses),
        AppRoutes.professorHome,
      );
      expect(
        redirectForSession(session, AppRoutes.qrScan),
        AppRoutes.professorHome,
      );
    });

    test('an admin cannot open an attendance session', () {
      final session = CurrentSession(role: UserRole.admin);

      expect(
        redirectForSession(session, AppRoutes.attendanceSession),
        AppRoutes.adminHome,
      );
    });

    test('unknown paths are not redirected', () {
      expect(redirectForSession(CurrentSession(), '/does-not-exist'), isNull);
    });

    test('the default temporary session is a student', () {
      expect(CurrentSession().role, UserRole.student);
    });
  });

  group('createAppRouter', () {
    late MockHomeCubit cubit;

    setUpAll(() => registerFallbackValue(UserRole.student));

    setUp(() {
      cubit = MockHomeCubit();
      when(() => cubit.state).thenReturn(const HomeLoaded([]));
      when(() => cubit.load(any())).thenAnswer((_) async {});
      getIt.registerFactory<HomeCubit>(() => cubit);
    });

    tearDown(() => getIt.reset());

    Future<GoRouter> pumpRouter(
      WidgetTester tester,
      CurrentSession session,
    ) async {
      final router = createAppRouter(session);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      return router;
    }

    String currentPath(GoRouter router) =>
        router.routerDelegate.currentConfiguration.uri.path;

    Finder homeOf(UserRole role) =>
        find.byWidgetPredicate((w) => w is HomePage && w.role == role);

    for (final role in UserRole.values) {
      testWidgets('starts on the ${role.name} home', (tester) async {
        final router = await pumpRouter(tester, CurrentSession(role: role));

        expect(currentPath(router), AppRoutes.homeFor(role));
        expect(homeOf(role), findsOneWidget);
      });
    }

    testWidgets('shows the login placeholder when signed out', (tester) async {
      final router = await pumpRouter(tester, CurrentSession(role: null));

      expect(currentPath(router), AppRoutes.login);
      expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    });

    testWidgets('a student cannot open the admin home', (tester) async {
      final router = await pumpRouter(tester, CurrentSession());

      router.go(AppRoutes.adminHome);
      await tester.pumpAndSettle();

      expect(currentPath(router), AppRoutes.studentHome);
      expect(homeOf(UserRole.student), findsOneWidget);
    });

    testWidgets('reacts to session changes', (tester) async {
      final session = CurrentSession();
      final router = await pumpRouter(tester, session);

      session.signInAs(UserRole.admin);
      await tester.pumpAndSettle();
      expect(currentPath(router), AppRoutes.adminHome);

      session.signOut();
      await tester.pumpAndSettle();
      expect(currentPath(router), AppRoutes.login);
    });

    // Each placeholder is opened with a role allowed to see it.
    final placeholders = {
      AppRoutes.timetable: ('Timetable', UserRole.student),
      AppRoutes.lectureDetailsPath('42'): ('Lecture 42', UserRole.student),
      AppRoutes.attendanceSession: ('Attendance session', UserRole.professor),
      AppRoutes.qrScan: ('Scan QR code', UserRole.student),
      AppRoutes.attendanceDashboard: (
        'Attendance dashboard',
        UserRole.professor,
      ),
      AppRoutes.myAttendance: ('My attendance', UserRole.student),
      AppRoutes.courses: ('Courses', UserRole.admin),
      AppRoutes.courseMembersPath('MOB-101'): (
        'Members of MOB-101',
        UserRole.admin,
      ),
      AppRoutes.settings: ('Settings', UserRole.student),
    };
    placeholders.forEach((path, entry) {
      final (title, role) = entry;
      testWidgets('$path shows the "$title" placeholder', (tester) async {
        final router = await pumpRouter(tester, CurrentSession(role: role));

        router.go(path);
        await tester.pumpAndSettle();

        expect(currentPath(router), path);
        expect(find.byType(PlaceholderPage), findsOneWidget);
        expect(find.widgetWithText(AppBar, title), findsOneWidget);
      });
    });

    testWidgets('a student cannot open the courses screen', (tester) async {
      final router = await pumpRouter(tester, CurrentSession());

      router.go(AppRoutes.courses);
      await tester.pumpAndSettle();

      expect(currentPath(router), AppRoutes.studentHome);
      expect(find.widgetWithText(AppBar, 'Courses'), findsNothing);
    });

    testWidgets('unknown routes show "Page not found"', (tester) async {
      final router = await pumpRouter(tester, CurrentSession());

      router.go('/does-not-exist');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Page not found'), findsOneWidget);
    });
  });
}
