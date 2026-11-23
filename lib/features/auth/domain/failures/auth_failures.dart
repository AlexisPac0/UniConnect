import 'package:uniconnect/core/error/failure.dart';

/// The email or the password is wrong, or one of them is missing.
///
/// Firebase does not tell which one is wrong (email enumeration protection),
/// so the message stays generic on purpose.
class InvalidCredentialsFailure extends AppFailure {
  const InvalidCredentialsFailure([
    super.message = 'Incorrect email or password.',
  ]);
}

/// The account exists but was disabled by an administrator.
class UserDisabledFailure extends AppFailure {
  const UserDisabledFailure([
    super.message = 'This account has been disabled. Contact your administrator.',
  ]);
}

/// Firebase temporarily blocks sign-in after too many failed attempts.
class TooManyAttemptsFailure extends AppFailure {
  const TooManyAttemptsFailure([
    super.message = 'Too many attempts. Please wait a moment and try again.',
  ]);
}
