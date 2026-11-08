import 'package:go_router/go_router.dart';
import 'package:uniconnect/core/router/app_routes.dart';
import 'package:uniconnect/core/session/current_session.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/widgets/placeholder_page.dart';
import 'package:uniconnect/features/home/presentation/pages/home_page.dart';

/// Builds the router of the app.
///
/// Screens that are not implemented yet use a [PlaceholderPage]; replace the
/// builder when the feature lands.
GoRouter createAppRouter(CurrentSession session) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: session,
    redirect: (_, state) => redirectForSession(session, state.uri.path),
    errorBuilder: (_, _) => const PlaceholderPage(title: 'Page not found'),
    routes: [
      GoRoute(path: AppRoutes.root, redirect: (_, _) => AppRoutes.login),
      // TODO(SCRUM-25): real login screen.
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const PlaceholderPage(title: 'Login'),
      ),
      GoRoute(
        path: AppRoutes.studentHome,
        builder: (_, _) => const HomePage(role: UserRole.student),
      ),
      GoRoute(
        path: AppRoutes.professorHome,
        builder: (_, _) => const HomePage(role: UserRole.professor),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (_, _) => const HomePage(role: UserRole.admin),
      ),
      GoRoute(
        path: AppRoutes.timetable,
        builder: (_, _) => const PlaceholderPage(title: 'Timetable'),
      ),
      GoRoute(
        path: AppRoutes.lectureDetails,
        builder: (_, state) => PlaceholderPage(
          title: 'Lecture ${state.pathParameters['lectureId']}',
        ),
      ),
      GoRoute(
        path: AppRoutes.attendanceSession,
        builder: (_, _) => const PlaceholderPage(title: 'Attendance session'),
      ),
      GoRoute(
        path: AppRoutes.qrScan,
        builder: (_, _) => const PlaceholderPage(title: 'Scan QR code'),
      ),
      GoRoute(
        path: AppRoutes.attendanceDashboard,
        builder: (_, _) => const PlaceholderPage(title: 'Attendance dashboard'),
      ),
      GoRoute(
        path: AppRoutes.myAttendance,
        builder: (_, _) => const PlaceholderPage(title: 'My attendance'),
      ),
      GoRoute(
        path: AppRoutes.courses,
        builder: (_, _) => const PlaceholderPage(title: 'Courses'),
      ),
      GoRoute(
        path: AppRoutes.courseMembers,
        builder: (_, state) => PlaceholderPage(
          title: 'Members of ${state.pathParameters['courseId']}',
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const PlaceholderPage(title: 'Settings'),
      ),
    ],
  );
}

/// Role-based redirect, kept as a pure function so it is easy to unit test.
///
/// - signed out: everything goes to the login screen;
/// - signed in: login, `/` and the home of another role go to the user's home.
///
/// Returns `null` when no redirect is needed.
///
/// TODO(SCRUM-25, SCRUM-28): read the role from the authentication feature and
/// add per-route permissions (e.g. only professors open attendance sessions).
String? redirectForSession(CurrentSession session, String location) {
  final role = session.role;
  if (role == null) {
    return location == AppRoutes.login ? null : AppRoutes.login;
  }

  final home = AppRoutes.homeFor(role);
  final isEntryPoint =
      location == AppRoutes.login || location == AppRoutes.root;
  final isOtherHome = AppRoutes.homes.contains(location) && location != home;
  if (isEntryPoint || isOtherHome) return home;

  return null;
}
