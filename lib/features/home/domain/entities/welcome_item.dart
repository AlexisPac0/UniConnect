import 'package:equatable/equatable.dart';

/// What happens when the user taps a [WelcomeItem] on the home screen.
///
/// The presentation layer maps each action to an icon and a route.
enum WelcomeAction {
  timetable,
  scanAttendance,
  myAttendance,
  startAttendanceSession,
  attendanceDashboard,
  manageCourses,
}

/// A shortcut displayed on the home screen.
class WelcomeItem extends Equatable {
  const WelcomeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.action,
  });

  final String id;
  final String title;
  final String description;
  final WelcomeAction action;

  @override
  List<Object?> get props => [id, title, description, action];
}
