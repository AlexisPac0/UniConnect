import 'package:equatable/equatable.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/failures/auth_failures.dart';
import 'package:uniconnect/features/auth/domain/repositories/auth_repository.dart';

/// Input of [SignInWithEmail].
class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Signs a user in with their email and password.
///
/// The email is trimmed. Empty fields are rejected without calling the
/// backend.
class SignInWithEmail extends UseCase<AuthUser, SignInParams> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call(SignInParams params) async {
    final email = params.email.trim();
    if (email.isEmpty || params.password.isEmpty) {
      return const Failure(
        InvalidCredentialsFailure('Please enter your email and password.'),
      );
    }
    return _repository.signInWithEmail(
      email: email,
      password: params.password,
    );
  }
}
