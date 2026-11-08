import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';

const tWelcomeItems = [
  WelcomeItem(
    id: 'timetable',
    title: 'Your timetable',
    description: 'See your lectures of the week.',
    action: WelcomeAction.timetable,
  ),
  WelcomeItem(
    id: 'attendance',
    title: 'Attendance check-in',
    description: 'Scan the QR code of the lecture.',
    action: WelcomeAction.scanAttendance,
  ),
];
