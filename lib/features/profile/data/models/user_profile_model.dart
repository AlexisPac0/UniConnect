import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';

/// Thrown by [UserProfileModel.fromMap] when the `role` field is missing or
/// is not one of `'student'`, `'professor'` or `'admin'`.
///
/// The repository converts it into an `InvalidRoleFailure`.
class InvalidRoleException implements Exception {
  const InvalidRoleException(this.value);

  /// Raw value found in the document, `null` when the field is missing.
  final Object? value;

  @override
  String toString() => 'InvalidRoleException: invalid user role "$value"';
}

/// Data representation of a [UserProfile], as stored in the Firestore
/// document `users/{id}`.
///
/// Models know how to (de)serialize themselves; entities do not.
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.studentNumber,
    this.department,
  });

  /// Builds a model from the [id] of the document and its [map] of fields.
  ///
  /// Fields other than those of [UserProfile] (`fcmTokens`, `createdAt`...)
  /// are ignored.
  ///
  /// Throws an [InvalidRoleException] if the role is missing or unknown, and
  /// a [FormatException] if another field is missing or has the wrong type.
  /// The repository converts these errors into a `Failure`.
  factory UserProfileModel.fromMap(String id, Map<String, dynamic> map) {
    final role = _parseRole(map['role']);
    final email = map['email'];
    final displayName = map['displayName'];
    final studentNumber = map['studentNumber'];
    final department = map['department'];
    if (email is! String ||
        displayName is! String ||
        studentNumber is! String? ||
        department is! String?) {
      throw FormatException('Invalid user profile "$id": $map');
    }
    return UserProfileModel(
      id: id,
      email: email,
      displayName: displayName,
      role: role,
      studentNumber: studentNumber,
      department: department,
    );
  }

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? studentNumber;
  final String? department;

  /// Converts the value stored in Firestore into a [UserRole].
  ///
  /// The stored strings are listed explicitly so that renaming a [UserRole]
  /// value cannot silently break the existing documents.
  static UserRole _parseRole(Object? value) {
    return switch (value) {
      'student' => UserRole.student,
      'professor' => UserRole.professor,
      'admin' => UserRole.admin,
      _ => throw InvalidRoleException(value),
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName,
      role: role,
      studentNumber: studentNumber,
      department: department,
    );
  }
}
