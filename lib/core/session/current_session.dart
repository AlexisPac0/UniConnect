import 'package:flutter/foundation.dart';
import 'package:uniconnect/core/session/user_role.dart';

/// TEMPORARY in-memory session holding the role of the current user.
///
/// It lets the router send each role to its own home before authentication
/// exists. The router listens to it, so calling [signInAs] or [signOut]
/// immediately triggers a new redirect.
///
/// TODO(SCRUM-25, SCRUM-28): replace with the authentication feature (Firebase
/// Auth + user profile holding the role) and delete this class.
class CurrentSession extends ChangeNotifier {
  CurrentSession({UserRole? role = UserRole.student}) : _role = role;

  UserRole? _role;

  /// Role of the signed-in user, or `null` when nobody is signed in.
  UserRole? get role => _role;

  bool get isSignedIn => _role != null;

  void signInAs(UserRole role) => _update(role);

  void signOut() => _update(null);

  void _update(UserRole? role) {
    if (_role == role) return;
    _role = role;
    notifyListeners();
  }
}
