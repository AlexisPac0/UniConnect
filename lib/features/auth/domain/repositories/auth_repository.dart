import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';

/// Contract of the authentication backend, implemented in the `data` layer.
///
/// Implementations must never throw: every error is returned as a `Failure`.
abstract interface class AuthRepository {
  /// Signs in with an email and a password.
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });
}
