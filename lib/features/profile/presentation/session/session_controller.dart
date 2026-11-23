import 'dart:async';

import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/app_session.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_out.dart';
import 'package:uniconnect/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:uniconnect/features/profile/domain/usecases/get_user_profile.dart';

/// Keeps the [AppSession] in sync with Firebase Auth and the user profile.
///
/// - nobody signed in: [AppSession.setSignedOut];
/// - a user signed in: [AppSession.setLoading], then [GetUserProfile]:
///   - success: [AppSession.setSignedIn] with the role of the profile;
///   - failure: [AppSession.setSignedOut] with the message of the failure,
///     then [SignOut], so that the user does not stay signed in to Firebase
///     without being able to use the app.
///
/// Restoring the session at startup needs nothing more: Firebase Auth keeps
/// the user signed in and emits them as the first event, which loads their
/// profile like any sign-in.
///
/// When the authentication state changes while a profile is loading, the
/// result of that load is ignored: only the latest event counts.
class SessionController {
  SessionController({
    required WatchAuthState watchAuthState,
    required GetUserProfile getUserProfile,
    required SignOut signOut,
    required AppSession session,
  }) : _watchAuthState = watchAuthState,
       _getUserProfile = getUserProfile,
       _signOut = signOut,
       _session = session;

  final WatchAuthState _watchAuthState;
  final GetUserProfile _getUserProfile;
  final SignOut _signOut;
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
  ///
  /// Synchronous, like `ChangeNotifier.dispose`: the cancellation is not
  /// awaited, since nothing can be emitted after [_generation] changed. This
  /// also lets widget tests dispose it inside their fake async zone.
  void dispose() {
    _generation++;
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  Future<void> _onAuthStateChanged(AuthUser? user) async {
    final generation = ++_generation;

    if (user == null) {
      // Keeps the reason of a previous forced sign-out, if any, so that the
      // login screen can still display it: the `null` emitted after the
      // [SignOut] below must not erase it.
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
        _session.setSignedOut(errorMessage: failure.message);
        // The session is already signed out, so a failure of SignOut is
        // ignored: it is not retried, which could loop.
        await _signOut(const NoParams());
    }
  }
}
