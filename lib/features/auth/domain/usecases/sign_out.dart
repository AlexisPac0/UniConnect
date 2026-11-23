import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/auth/domain/repositories/auth_repository.dart';

/// Signs the current user out.
///
/// On success, the authentication state becomes `null`, which signs the app
/// session out: callers do not need to navigate themselves.
class SignOut extends UseCase<void, NoParams> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.signOut();
}
