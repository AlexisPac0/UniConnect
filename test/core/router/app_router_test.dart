import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/core/router/app_router.dart';
import 'package:uniconnect/core/router/app_routes.dart';
import 'package:uniconnect/core/session/current_session.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/widgets/placeholder_page.dart';
import 'package:uniconnect/features/courses/data/datasources/course_data_source.dart';
import 'package:uniconnect/features/courses/data/repositories/course_repository_impl.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';
import 'package:uniconnect/features/courses/presentation/cubit/course_cubit.dart';
import 'package:uniconnect/features/courses/presentation/pages/course_page.dart';
import 'package:uniconnect/features/home/presentation/cubit/home_cubit.dart';
import 'package:uniconnect/features/home/presentation/pages/home_page.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
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
      });
    }

    test('the default temporary session is an admin', () {
      expect(CurrentSession().role, UserRole.admin);
    });

    test('only admins can open course management', () {
      for (final role in [UserRole.student, UserRole.professor]) {
        final session = CurrentSession(role: role);
        expect(
          redirectForSession(session, AppRoutes.courses),
          AppRoutes.homeFor(role),
        );
      }
      expect(
        redirectForSession(
          CurrentSession(role: UserRole.admin),
          AppRoutes.courses,
        ),
        isNull,
      );
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
      getIt.registerFactory<CourseCubit>(
        () => CourseCubit(
          const CreateCourse(CourseRepositoryImpl(FakeCourseDataSource())),
        ),
      );
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
      final router = await pumpRouter(
        tester,
        CurrentSession(role: UserRole.student),
      );

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

    final placeholders = {
      AppRoutes.timetable: 'Timetable',
      AppRoutes.lectureDetailsPath('42'): 'Lecture 42',
      AppRoutes.attendanceSession: 'Attendance session',
      AppRoutes.qrScan: 'Scan QR code',
      AppRoutes.attendanceDashboard: 'Attendance dashboard',
      AppRoutes.myAttendance: 'My attendance',
      AppRoutes.courseMembersPath('MOB-101'): 'Members of MOB-101',
      AppRoutes.settings: 'Settings',
    };
    placeholders.forEach((path, title) {
      testWidgets('$path shows the "$title" placeholder', (tester) async {
        final router = await pumpRouter(tester, CurrentSession());

        router.go(path);
        await tester.pumpAndSettle();

        expect(currentPath(router), path);
        expect(find.byType(PlaceholderPage), findsOneWidget);
        expect(find.widgetWithText(AppBar, title), findsOneWidget);
      });
    });

    testWidgets('/courses shows the course creation form', (tester) async {
      final router = await pumpRouter(tester, CurrentSession());

      router.go(AppRoutes.courses);
      await tester.pumpAndSettle();

      expect(currentPath(router), AppRoutes.courses);
      expect(find.byType(CoursePage), findsOneWidget);
      expect(find.text('Create a course'), findsOneWidget);
    });

    testWidgets('unknown routes show "Page not found"', (tester) async {
      final router = await pumpRouter(tester, CurrentSession());

      router.go('/does-not-exist');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Page not found'), findsOneWidget);
    });
  });
}
