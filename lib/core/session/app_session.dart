import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uniconnect/core/session/user_role.dart';

/// Who is using the app, as seen by the router and the screens.
///
/// The `switch` on a [SessionState] is exhaustive:
///
/// ```dart
/// switch (session.state) {
///   case SessionLoading(): ...
///   case SessionSignedOut(:final errorMessage): ...
///   case SessionSignedIn(:final role): ...
/// }
/// ```
sealed class SessionState extends Equatable {
  const SessionState();
}

/// The app does not know yet who is signed in: at startup, or while the
/// profile of the user who just signed in is loading.
final class SessionLoading extends SessionState {
  const SessionLoading();

  @override
  List<Object?> get props => [];
}

/// Nobody is signed in.
final class SessionSignedOut extends SessionState {
  const SessionSignedOut({this.errorMessage});

  /// Why the user was signed out (profile not found, invalid role...), or
  /// `null` for a normal sign-out.
  final String? errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

/// A user is signed in and their profile is loaded.
final class SessionSignedIn extends SessionState {
  const SessionSignedIn({
    required this.userId,
    required this.role,
    required this.displayName,
  });

  final String userId;
  final UserRole role;
  final String displayName;

  @override
  List<Object?> get props => [userId, role, displayName];
}

/// Holds the current [SessionState] and notifies its listeners (the router)
/// when it changes.
///
/// It is fed by the profile feature (`SessionController`); `core` does not
/// know where the state comes from.
class AppSession extends ChangeNotifier {
  /// Starts in [initial], [SessionLoading] by default. Tests can start
  /// directly in another state.
  AppSession([SessionState initial = const SessionLoading()])
    : _state = initial;

  SessionState _state;

  SessionState get state => _state;

  bool get isSignedIn => _state is SessionSignedIn;

  /// Role of the signed-in user, or `null` when nobody is signed in.
  UserRole? get role => switch (_state) {
    SessionSignedIn(:final role) => role,
    _ => null,
  };

  /// Why the user was signed out, if any.
  String? get errorMessage => switch (_state) {
    SessionSignedOut(:final errorMessage) => errorMessage,
    _ => null,
  };

  void setLoading() => _update(const SessionLoading());

  void setSignedOut({String? errorMessage}) {
    _update(SessionSignedOut(errorMessage: errorMessage));
  }

  void setSignedIn({
    required String userId,
    required UserRole role,
    required String displayName,
  }) {
    _update(
      SessionSignedIn(userId: userId, role: role, displayName: displayName),
    );
  }

  void _update(SessionState state) {
    if (state == _state) return;
    _state = state;
    notifyListeners();
  }
}
