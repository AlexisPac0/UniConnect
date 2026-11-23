import 'package:firebase_auth/firebase_auth.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';

/// Low-level access to Firebase Authentication. Implementations may throw,
/// in particular a [FirebaseAuthException].
abstract interface class AuthDataSource {
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });
}

/// [AuthDataSource] backed by the Firebase Auth SDK.
class FirebaseAuthDataSource implements AuthDataSource {
  const FirebaseAuthDataSource(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase returned no user after sign-in.');
    }
    return AuthUser(id: user.uid, email: user.email ?? email);
  }
}
