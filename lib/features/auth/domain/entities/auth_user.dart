import 'package:equatable/equatable.dart';

/// The user signed in with Firebase Authentication.
///
/// It only holds the identity. The role lives in the user profile stored in
/// Firestore (`users/{id}`) and will be loaded separately (SCRUM-28).
class AuthUser extends Equatable {
  const AuthUser({required this.id, required this.email});

  /// Firebase Auth UID, also the id of the `users/{id}` document.
  final String id;

  final String email;

  @override
  List<Object?> get props => [id, email];
}
