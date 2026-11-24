import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/widgets/app_button.dart';
import 'package:uniconnect/core/widgets/error_state.dart';

import '../../helpers/pump_themed.dart';

void main() {
  testWidgets('shows the title, message and error icon', (tester) async {
    await pumpThemed(tester, const ErrorState(message: 'No connection'));

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('No connection'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('the retry button fires onRetry', (tester) async {
    var retries = 0;
    await pumpThemed(
      tester,
      ErrorState(message: 'No connection', onRetry: () => retries++),
    );

    await tester.tap(find.text('Retry'));

    expect(retries, 1);
  });
}
