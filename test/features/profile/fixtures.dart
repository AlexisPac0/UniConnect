import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';

const tUserId = 'user-123';

const tStudentProfile = UserProfile(
  id: tUserId,
  email: 'jane.doe@university.hr',
  displayName: 'Jane Doe',
  role: UserRole.student,
  studentNumber: '0036512345',
  department: 'Computer Science',
);
