import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_in_with_email.dart';

part 'login_state.dart';

/// State of the login screen. Depends on the domain only.
///
/// It does not navigate: once Firebase Auth signs the user in, the
/// `SessionController` loads the profile and the router redirects to the
/// home of the user's role.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._signInWithEmail) : super(const LoginInitial());

  final SignInWithEmail _signInWithEmail;

  /// Signs in with [email] and [password]. Does nothing while a previous
  /// attempt is running or has already succeeded.
  Future<void> signIn({required String email, required String password}) async {
    if (state is LoginSubmitting || state is LoginSuccess) return;

    emit(const LoginSubmitting());
    final result = await _signInWithEmail(
      SignInParams(email: email, password: password),
    );
    if (isClosed) return;
    emit(switch (result) {
      Success() => const LoginSuccess(),
      Failure(:final failure) => LoginFailure(failure.message),
    });
  }
}
