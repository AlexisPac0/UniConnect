import 'package:firebase_auth/firebase_auth.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/auth/data/datasources/auth_data_source.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/failures/auth_failures.dart';
import 'package:uniconnect/features/auth/domain/repositories/auth_repository.dart';

/// [AuthRepository] backed by an [AuthDataSource].
///
/// Converts every thrown error into a `Failure`, and Firebase error codes
/// into the failures of the auth feature.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Success(user);
    } on FirebaseAuthException catch (error) {
      return Failure(_mapFirebaseError(error));
    } catch (error) {
      return Failure(
        UnexpectedFailure(
          message: 'Could not sign you in. Please try again.',
          cause: error,
        ),
      );
    }
  }

  AppFailure _mapFirebaseError(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-credential' ||
      'invalid-email' ||
      'user-not-found' ||
      'wrong-password' => const InvalidCredentialsFailure(),
      'user-disabled' => const UserDisabledFailure(),
      'too-many-requests' => const TooManyAttemptsFailure(),
      'network-request-failed' => const NetworkFailure(),
      _ => UnexpectedFailure(
        message: 'Could not sign you in. Please try again.',
        cause: error,
      ),
    };
  }
}
