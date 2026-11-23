import 'dart:async';

import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/app_session.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:uniconnect/features/profile/domain/usecases/get_user_profile.dart';

/// Keeps the [AppSession] in sync with Firebase Auth and the user profile.
///
/// - nobody signed in: [AppSession.setSignedOut];
/// - a user signed in: [AppSession.setLoading], then [GetUserProfile]:
///   - success: [AppSession.setSignedIn] with the role of the profile;
///   - failure: [AppSession.setSignedOut] with the message of the failure.
///
/// When the authentication state changes while a profile is loading, the
/// result of that load is ignored: only the latest event counts.
class SessionController {
  SessionController({
    required WatchAuthState watchAuthState,
    required GetUserProfile getUserProfile,
    required AppSession session,
  }) : _watchAuthState = watchAuthState,
       _getUserProfile = getUserProfile,
       _session = session;

  final WatchAuthState _watchAuthState;
  final GetUserProfile _getUserProfile;
  final AppSession _session;

  StreamSubscription<AuthUser?>? _subscription;

  /// Incremented on every authentication event and on [dispose], so that a
  /// profile load can tell whether its result is still wanted.
  int _generation = 0;

  /// Starts listening to the authentication state. Calling it again while
  /// started does nothing.
  void start() {
    _subscription ??= _watchAuthState().listen(_onAuthStateChanged);
  }

  /// Stops listening. Results of profile loads still running are ignored.
  Future<void> dispose() async {
    _generation++;
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
  }

  Future<void> _onAuthStateChanged(AuthUser? user) async {
    final generation = ++_generation;

    if (user == null) {
      // Keeps the reason of a previous forced sign-out, if any, so that the
      // login screen can still display it.
      _session.setSignedOut(errorMessage: _session.errorMessage);
      return;
    }

    _session.setLoading();
    final result = await _getUserProfile(user.id);
    if (generation != _generation) return;

    switch (result) {
      case Success(value: final profile):
        _session.setSignedIn(
          userId: user.id,
          role: profile.role,
          displayName: profile.displayName,
        );
      case Failure(:final failure):
        // TODO(SCRUM-26): also sign out of Firebase Auth, otherwise the user
        // stays signed in there without being able to use the app.
        _session.setSignedOut(errorMessage: failure.message);
    }
  }
}
