import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/profile/domain/entities/app_feature.dart';
import 'package:uniconnect/features/profile/domain/policies/role_access_policy.dart';

void main() {
  const policy = RoleAccessPolicy();

  /// Expected access matrix, written out in full on purpose: any change to
  /// the rules must be reflected here.
  const expected = <AppFeature, Set<UserRole>>{
    AppFeature.timetable: {
      UserRole.student,
      UserRole.professor,
      UserRole.admin,
    },
    AppFeature.attendanceCheckIn: {UserRole.student},
    AppFeature.myAttendance: {UserRole.student},
    AppFeature.attendanceSession: {UserRole.professor},
    AppFeature.attendanceDashboard: {UserRole.professor, UserRole.admin},
    AppFeature.courseManagement: {UserRole.admin},
    AppFeature.settings: {UserRole.student, UserRole.professor, UserRole.admin},
  };

  test('the expected matrix covers every feature', () {
    expect(expected.keys.toSet(), AppFeature.values.toSet());
  });

  for (final feature in AppFeature.values) {
    for (final role in UserRole.values) {
      final allowed = expected[feature]!.contains(role);
      test(
        '${role.name} ${allowed ? 'can' : 'cannot'} access ${feature.name}',
        () {
          expect(policy.canAccess(role, feature), allowed);
        },
      );
    }
  }

  test('featuresOf is consistent with canAccess', () {
    for (final role in UserRole.values) {
      expect(
        policy.featuresOf(role),
        AppFeature.values.where((f) => policy.canAccess(role, f)).toSet(),
      );
    }
  });
}
