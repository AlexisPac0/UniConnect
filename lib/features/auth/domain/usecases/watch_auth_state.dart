import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/repositories/auth_repository.dart';

/// Watches who is signed in: emits the current [AuthUser], or `null` when
/// nobody is signed in, then every change.
///
/// Not a `UseCase`, which returns a single `Future`: this one returns a
/// `Stream` that never emits an error.
class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AuthUser?> call() => _repository.authStateChanges();
}
