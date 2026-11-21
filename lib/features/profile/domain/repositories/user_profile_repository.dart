import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';

/// Contract of the user profile source, implemented in the `data` layer.
///
/// Implementations must never throw: every error is returned as a `Failure`.
abstract interface class UserProfileRepository {
  /// Returns the profile of the user identified by [userId].
  ///
  /// Expected failures:
  /// - `ProfileNotFoundFailure` when the document `users/{userId}` is missing;
  /// - `InvalidRoleFailure` when the stored role is not a known `UserRole`;
  /// - any other `AppFailure` (e.g. `NetworkFailure`) for technical errors.
  Future<Result<UserProfile>> getUserProfile(String userId);
}
