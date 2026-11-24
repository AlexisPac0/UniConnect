import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_out.dart';

part 'sign_out_state.dart';

/// Signs the user out. Depends on the domain only.
///
/// On success it goes back to [SignOutIdle] and does not navigate: Firebase
/// Auth emits `null`, the `SessionController` signs the `AppSession` out, and
/// the router redirects to the login screen by itself.
class SignOutCubit extends Cubit<SignOutState> {
  SignOutCubit(this._signOut) : super(const SignOutIdle());

  final SignOut _signOut;

  Future<void> signOut() async {
    if (state is SignOutInProgress) return;
    emit(const SignOutInProgress());
    final result = await _signOut(const NoParams());
    // The screen is usually gone once the session is signed out.
    if (isClosed) return;
    emit(switch (result) {
      Success() => const SignOutIdle(),
      Failure(:final failure) => SignOutError(failure.message),
    });
  }
}
