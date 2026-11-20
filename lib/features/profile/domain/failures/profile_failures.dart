import 'package:uniconnect/core/error/failure.dart';

/// No profile exists for the user: the document `users/{id}` is missing.
class ProfileNotFoundFailure extends AppFailure {
  const ProfileNotFoundFailure([
    super.message =
        'Your user profile could not be found. Please contact an administrator.',
  ]);
}

/// The role stored in the user profile is not a known `UserRole`.
class InvalidRoleFailure extends AppFailure {
  const InvalidRoleFailure([
    super.message =
        'Your account has an invalid role. Please contact an administrator.',
  ]);
}
