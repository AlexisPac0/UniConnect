import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/profile/domain/entities/app_feature.dart';

/// Decides which [AppFeature]s each [UserRole] can use.
///
/// Single source of truth for role-based access: the router uses it to block
/// the screens of other roles. The `switch` is exhaustive, so adding a role
/// does not compile until its features are declared here.
class RoleAccessPolicy {
  const RoleAccessPolicy();

  /// Returns every feature available to [role].
  Set<AppFeature> featuresOf(UserRole role) {
    return switch (role) {
      UserRole.student => const {
        AppFeature.timetable,
        AppFeature.attendanceCheckIn,
        AppFeature.myAttendance,
        AppFeature.settings,
      },
      UserRole.professor => const {
        AppFeature.timetable,
        AppFeature.attendanceSession,
        AppFeature.attendanceDashboard,
        AppFeature.settings,
      },
      UserRole.admin => const {
        AppFeature.timetable,
        AppFeature.attendanceDashboard,
        AppFeature.courseManagement,
        AppFeature.settings,
      },
    };
  }

  /// Whether [role] can use [feature].
  bool canAccess(UserRole role, AppFeature feature) {
    return featuresOf(role).contains(feature);
  }
}
