import 'package:equatable/equatable.dart';
import 'package:uniconnect/core/session/user_role.dart';

/// Profile of a UniConnect user, stored in the Firestore document `users/{id}`.
///
/// Authentication only provides the [id] and [email]; the profile adds the
/// [role] that decides which features the user can access.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.studentNumber,
    this.department,
  });

  /// Identifier of the user, the same as the authentication user id.
  final String id;

  final String email;

  /// Name displayed in the UI.
  final String displayName;

  final UserRole role;

  /// Student number, usually only set for students.
  final String? studentNumber;

  /// Department the user belongs to, if any.
  final String? department;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    role,
    studentNumber,
    department,
  ];
}
