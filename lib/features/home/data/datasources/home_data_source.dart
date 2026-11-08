import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/home/data/models/welcome_item_model.dart';

/// Low-level access to the home content. Implementations may throw.
abstract interface class HomeDataSource {
  Future<List<WelcomeItemModel>> getWelcomeItems(UserRole role);
}

/// In-memory implementation used until the Firebase backend exists.
///
/// TODO(SCRUM-13): replace with a Firestore-backed data source.
class InMemoryHomeDataSource implements HomeDataSource {
  const InMemoryHomeDataSource();

  static const Map<UserRole, List<Map<String, Object?>>> _itemsByRole = {
    UserRole.student: [
      {
        'id': 'student-timetable',
        'title': 'Your timetable',
        'description':
            'See your lectures of the week and get notified when one changes.',
        'action': 'timetable',
      },
      {
        'id': 'student-check-in',
        'title': 'Attendance check-in',
        'description':
            'Scan the QR code shown in the lecture room to confirm your '
            'attendance.',
        'action': 'scanAttendance',
      },
      {
        'id': 'student-attendance',
        'title': 'My attendance',
        'description': 'Follow your attendance rate for each course.',
        'action': 'myAttendance',
      },
    ],
    UserRole.professor: [
      {
        'id': 'professor-timetable',
        'title': 'Your teaching schedule',
        'description': 'See your upcoming lectures and update sessions.',
        'action': 'timetable',
      },
      {
        'id': 'professor-session',
        'title': 'Start an attendance session',
        'description': 'Display a QR code so that students can check in.',
        'action': 'startAttendanceSession',
      },
      {
        'id': 'professor-dashboard',
        'title': 'Attendance',
        'description': 'Review attendance statistics for your courses.',
        'action': 'attendanceDashboard',
      },
    ],
    UserRole.admin: [
      {
        'id': 'admin-courses',
        'title': 'Courses',
        'description': 'Create courses and assign professors and students.',
        'action': 'manageCourses',
      },
      {
        'id': 'admin-timetable',
        'title': 'Timetable',
        'description': 'Manage lectures and the university schedule.',
        'action': 'timetable',
      },
      {
        'id': 'admin-attendance',
        'title': 'Attendance overview',
        'description': 'Monitor attendance across all courses.',
        'action': 'attendanceDashboard',
      },
    ],
  };

  @override
  Future<List<WelcomeItemModel>> getWelcomeItems(UserRole role) async {
    final items = _itemsByRole[role] ?? const [];
    return items.map(WelcomeItemModel.fromMap).toList();
  }
}
