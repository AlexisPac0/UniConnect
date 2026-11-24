part of 'sign_out_cubit.dart';

sealed class SignOutState extends Equatable {
  const SignOutState();

  @override
  List<Object?> get props => [];
}

/// Nothing is happening: the button can be used.
final class SignOutIdle extends SignOutState {
  const SignOutIdle();
}

final class SignOutInProgress extends SignOutState {
  const SignOutInProgress();
}

final class SignOutError extends SignOutState {
  const SignOutError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
