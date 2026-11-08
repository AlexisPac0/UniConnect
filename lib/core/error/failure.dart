import 'package:equatable/equatable.dart';

/// Base type for every expected error in the app.
///
/// Repositories catch low-level exceptions (network, Firebase, parsing...)
/// and convert them into an [AppFailure] wrapped in a `Failure` result, so
/// that no exception ever reaches the presentation layer.
///
/// Features may declare their own failures by extending this class
/// (e.g. `QrCodeExpiredFailure` in the attendance feature).
abstract class AppFailure extends Equatable {
  const AppFailure(this.message);

  /// Human readable message that can be displayed to the user.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// The device is offline or the backend could not be reached.
class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Please check your internet connection and try again.',
  ]);
}

/// The requested resource does not exist.
class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'The requested item was not found.']);
}

/// The current user is not allowed to perform the action.
class PermissionFailure extends AppFailure {
  const PermissionFailure([
    super.message = 'You are not allowed to perform this action.',
  ]);
}

/// Any error that was not anticipated.
///
/// [cause] keeps the original error for logging and debugging; it is not part
/// of equality.
class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({
    String message = 'Something went wrong. Please try again.',
    this.cause,
  }) : super(message);

  final Object? cause;
}
