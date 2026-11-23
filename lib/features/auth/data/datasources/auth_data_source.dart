import 'package:firebase_auth/firebase_auth.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';

/// Low-level access to Firebase Authentication. Implementations may throw,
/// in particular a [FirebaseAuthException].
abstract interface class AuthDataSource {
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Emits the signed-in user, or `null` when nobody is signed in.
  /// The stream may emit errors.
  Stream<AuthUser?> authStateChanges();
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

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(
      (user) => user == null ? null : _toAuthUser(user),
    );
  }

  /// A user signed in without an email (not possible with the providers of
  /// UniConnect) gets an empty one rather than failing.
  static AuthUser _toAuthUser(User user) {
    return AuthUser(id: user.uid, email: user.email ?? '');
  }
}
