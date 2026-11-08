import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/app.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/core/session/current_session.dart';
import 'package:uniconnect/core/session/user_role.dart';

/// End-to-end smoke tests with the real dependency graph.
void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(UniConnectApp(router: getIt<GoRouter>()));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the student home by default', (tester) async {
    await pumpApp(tester);

    expect(find.text('Student space'), findsOneWidget);
    expect(find.text('Your timetable'), findsOneWidget);
  });

  testWidgets('opens the timetable from the home and goes back', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Your timetable'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Timetable'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Student space'), findsOneWidget);
  });

  testWidgets('switching the session role shows the matching home', (
    tester,
  ) async {
    await pumpApp(tester);

    getIt<CurrentSession>().signInAs(UserRole.professor);
    await tester.pumpAndSettle();

    expect(find.text('Professor space'), findsOneWidget);
    expect(find.text('Start an attendance session'), findsOneWidget);
  });
}
