import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/profile/data/models/user_profile_model.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';

import '../../fixtures.dart';

void main() {
  /// A complete `users/{id}` document, including fields the model ignores.
  Map<String, dynamic> document({Object? role = 'student'}) => {
    'id': tUserId,
    'email': 'jane.doe@university.hr',
    'displayName': 'Jane Doe',
    'role': ?role,
    'studentNumber': '0036512345',
    'department': 'Computer Science',
    'fcmTokens': ['token-1', 'token-2'],
    'createdAt': Timestamp.fromDate(DateTime.utc(2026, 9, 1)),
  };

  test('fromMap then toEntity builds the complete profile', () {
    final model = UserProfileModel.fromMap(tUserId, document());

    expect(model.toEntity(), tStudentProfile);
  });

  test('optional fields are null when absent', () {
    final model = UserProfileModel.fromMap(tUserId, const {
      'id': tUserId,
      'email': 'john.smith@university.hr',
      'displayName': 'John Smith',
      'role': 'professor',
    });

    expect(
      model.toEntity(),
      const UserProfile(
        id: tUserId,
        email: 'john.smith@university.hr',
        displayName: 'John Smith',
        role: UserRole.professor,
      ),
    );
  });

  const roles = {
    'student': UserRole.student,
    'professor': UserRole.professor,
    'admin': UserRole.admin,
  };

  test('every UserRole has a stored value', () {
    expect(roles.values.toSet(), UserRole.values.toSet());
  });

  roles.forEach((value, role) {
    test('"$value" is converted to UserRole.${role.name}', () {
      final model = UserProfileModel.fromMap(tUserId, document(role: value));

      expect(model.role, role);
      expect(model.toEntity().role, role);
    });
  });

  for (final role in ['teacher', 'Student', '', 42]) {
    test('an unknown role ${role is String ? '"$role"' : role} throws', () {
      expect(
        () => UserProfileModel.fromMap(tUserId, document(role: role)),
        throwsA(
          isA<InvalidRoleException>().having((e) => e.value, 'value', role),
        ),
      );
    });
  }

  test('a missing role throws an InvalidRoleException', () {
    expect(
      () => UserProfileModel.fromMap(tUserId, document(role: null)),
      throwsA(
        isA<InvalidRoleException>().having((e) => e.value, 'value', isNull),
      ),
    );
  });

  test('a missing required field throws a FormatException', () {
    expect(
      () => UserProfileModel.fromMap(tUserId, {...document()}..remove('email')),
      throwsFormatException,
    );
  });

  test('an optional field of the wrong type throws a FormatException', () {
    expect(
      () => UserProfileModel.fromMap(tUserId, {
        ...document(),
        'studentNumber': 36512345,
      }),
      throwsFormatException,
    );
  });
}
