import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/app.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/core/session/app_session.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/widgets/splash_page.dart';

/// End-to-end smoke tests with the real dependency graph.
///
/// Firebase is never touched: the `SessionController` is not started, and
/// the [AppSession] is set directly, as the controller would do.
void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  AppSession session() => getIt<AppSession>();

  void signInAs(UserRole role) {
    session().setSignedIn(
      userId: 'user-1',
      role: role,
      displayName: 'Test user',
    );
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(UniConnectApp(router: getIt<GoRouter>()));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the splash screen while the session is loading', (
    tester,
  ) async {
    await tester.pumpWidget(UniConnectApp(router: getIt<GoRouter>()));
    await tester.pump();

    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('shows the login screen when signed out', (tester) async {
    session().setSignedOut();
    await pumpApp(tester);

    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
  });

  testWidgets('a signed-in student starts on the student home', (tester) async {
    signInAs(UserRole.student);
    await pumpApp(tester);

    expect(find.text('Student space'), findsOneWidget);
    expect(find.text('Your timetable'), findsOneWidget);
  });

  testWidgets('opens the timetable from the home and goes back', (
    tester,
  ) async {
    signInAs(UserRole.student);
    await pumpApp(tester);

    await tester.tap(find.text('Your timetable'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Timetable'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Student space'), findsOneWidget);
  });

  testWidgets('leaves the splash screen once the profile is loaded', (
    tester,
  ) async {
    await tester.pumpWidget(UniConnectApp(router: getIt<GoRouter>()));
    await tester.pump();

    signInAs(UserRole.professor);
    await tester.pumpAndSettle();

    expect(find.text('Professor space'), findsOneWidget);
    expect(find.text('Start an attendance session'), findsOneWidget);
  });

  testWidgets('switching the session role shows the matching home', (
    tester,
  ) async {
    signInAs(UserRole.student);
    await pumpApp(tester);

    signInAs(UserRole.professor);
    await tester.pumpAndSettle();

    expect(find.text('Professor space'), findsOneWidget);
  });
}
