import 'package:flutter_test/flutter_test.dart';

import 'package:uniconnect/app.dart';

void main() {
  testWidgets('renders the UniConnect app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const UniConnectApp());

    expect(find.text('UniConnect'), findsOneWidget);
    expect(find.text('Welcome to UniConnect'), findsOneWidget);
    expect(find.text('Stay informed'), findsOneWidget);
  });
}
