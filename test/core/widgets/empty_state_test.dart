import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/widgets/app_button.dart';
import 'package:uniconnect/core/widgets/empty_state.dart';

import '../../helpers/pump_themed.dart';

void main() {
  testWidgets('shows the icon, title and message', (tester) async {
    await pumpThemed(
      tester,
      const EmptyState(
        icon: Icons.event_busy,
        title: 'No lectures',
        message: 'Nothing scheduled today.',
      ),
    );

    expect(find.byIcon(Icons.event_busy), findsOneWidget);
    expect(find.text('No lectures'), findsOneWidget);
    expect(find.text('Nothing scheduled today.'), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('the action button fires onAction', (tester) async {
    var taps = 0;
    await pumpThemed(
      tester,
      EmptyState(
        title: 'No courses',
        actionLabel: 'Add a course',
        onAction: () => taps++,
      ),
    );

    await tester.tap(find.text('Add a course'));

    expect(taps, 1);
  });

  testWidgets('hides the action without a callback', (tester) async {
    await pumpThemed(
      tester,
      const EmptyState(title: 'No courses', actionLabel: 'Add a course'),
    );

    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('a custom illustration replaces the icon', (tester) async {
    await pumpThemed(
      tester,
      const EmptyState(title: 'Empty', illustration: FlutterLogo()),
    );

    expect(find.byType(FlutterLogo), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsNothing);
  });

  testWidgets('marks the title as a header for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(tester, const EmptyState(title: 'No lectures'));

    expect(
      tester.getSemantics(find.text('No lectures')),
      matchesSemantics(label: 'No lectures', isHeader: true),
    );
    handle.dispose();
  });
}
