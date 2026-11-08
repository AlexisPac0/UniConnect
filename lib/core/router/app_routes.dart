import 'package:uniconnect/core/session/user_role.dart';

/// Paths of every main screen. Always navigate with these constants
/// (`context.push(AppRoutes.timetable)`), never with raw strings.
abstract final class AppRoutes {
  static const String root = '/';
  static const String login = '/login';

  // Homes, one per role.
  static const String studentHome = '/student';
  static const String professorHome = '/professor';
  static const String adminHome = '/admin';

  // Timetable module.
  static const String timetable = '/timetable';
  static const String lectureDetails = '/timetable/lectures/:lectureId';

  // Attendance module.
  static const String attendanceSession = '/attendance/session';
  static const String qrScan = '/attendance/scan';
  static const String attendanceDashboard = '/attendance/dashboard';
  static const String myAttendance = '/attendance/me';

  // Course management.
  static const String courses = '/courses';
  static const String courseMembers = '/courses/:courseId/members';

  static const String settings = '/settings';

  static const Set<String> homes = {studentHome, professorHome, adminHome};

  static String lectureDetailsPath(String lectureId) =>
      '/timetable/lectures/${Uri.encodeComponent(lectureId)}';

  static String courseMembersPath(String courseId) =>
      '/courses/${Uri.encodeComponent(courseId)}/members';

  static String homeFor(UserRole role) {
    return switch (role) {
      UserRole.student => studentHome,
      UserRole.professor => professorHome,
      UserRole.admin => adminHome,
    };
  }
}
