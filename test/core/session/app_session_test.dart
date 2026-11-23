import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/session/app_session.dart';
import 'package:uniconnect/core/session/user_role.dart';

void main() {
  late AppSession session;
  late int notifications;

  setUp(() {
    session = AppSession();
    notifications = 0;
    session.addListener(() => notifications++);
  });

  tearDown(() => session.dispose());

  void signInAsStudent() {
    session.setSignedIn(
      userId: 'user-1',
      role: UserRole.student,
      displayName: 'Jane Doe',
    );
  }

  test('starts loading by default', () {
    expect(session.state, const SessionLoading());
    expect(session.isSignedIn, isFalse);
    expect(session.role, isNull);
    expect(session.errorMessage, isNull);
  });

  test('can start in another state', () {
    final signedOut = AppSession(const SessionSignedOut());
    addTearDown(signedOut.dispose);

    expect(signedOut.state, const SessionSignedOut());
  });

  test('setSignedIn exposes the user, the role and the name', () {
    signInAsStudent();

    expect(
      session.state,
      const SessionSignedIn(
        userId: 'user-1',
        role: UserRole.student,
        displayName: 'Jane Doe',
      ),
    );
    expect(session.isSignedIn, isTrue);
    expect(session.role, UserRole.student);
    expect(notifications, 1);
  });

  test('setSignedOut keeps the optional error message', () {
    session.setSignedOut(errorMessage: 'Profile not found');

    expect(
      session.state,
      const SessionSignedOut(errorMessage: 'Profile not found'),
    );
    expect(session.errorMessage, 'Profile not found');
    expect(session.role, isNull);
  });

  test('goes back to loading', () {
    signInAsStudent();

    session.setLoading();

    expect(session.state, const SessionLoading());
    expect(session.role, isNull);
    expect(notifications, 2);
  });

  test('notifies only when the state changes', () {
    session.setLoading();
    expect(notifications, 0);

    signInAsStudent();
    signInAsStudent();
    expect(notifications, 1);

    session
      ..setSignedOut()
      ..setSignedOut();
    expect(notifications, 2);

    session.setSignedOut(errorMessage: 'Invalid role');
    expect(notifications, 3);

    session.setSignedIn(
      userId: 'user-1',
      role: UserRole.admin,
      displayName: 'Jane Doe',
    );
    expect(notifications, 4);
  });
}
