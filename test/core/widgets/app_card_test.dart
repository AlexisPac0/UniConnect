import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/widgets/app_card.dart';

import '../../helpers/pump_themed.dart';

void main() {
  testWidgets('renders the child inside a Card', (tester) async {
    await pumpThemed(tester, const AppCard(child: Text('Body')));

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('renders the header and footer', (tester) async {
    await pumpThemed(
      tester,
      const AppCard(
        header: Text('Header'),
        footer: Text('Footer'),
        child: Text('Body'),
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Header')).dy,
      lessThan(tester.getTopLeft(find.text('Body')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Footer')).dy,
      greaterThan(tester.getTopLeft(find.text('Body')).dy),
    );
  });

  testWidgets('calls onTap with an ink ripple', (tester) async {
    var taps = 0;
    await pumpThemed(
      tester,
      AppCard(onTap: () => taps++, child: const Text('Body')),
    );

    expect(find.byType(InkWell), findsOneWidget);
    await tester.tap(find.text('Body'));

    expect(taps, 1);
  });
}
