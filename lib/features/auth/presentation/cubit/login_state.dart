part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Waiting for the user to fill in the form.
final class LoginInitial extends LoginState {
  const LoginInitial();
}

/// The sign-in request is running.
final class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

/// Firebase Auth accepted the credentials. The screen keeps showing progress
/// until the router leaves it.
final class LoginSuccess extends LoginState {
  const LoginSuccess();
}

/// The sign-in failed. [message] can be shown to the user.
final class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
