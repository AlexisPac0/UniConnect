import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/app.dart';
import 'package:uniconnect/core/di/injection.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  testWidgets('starts on the student home with real dependencies', (
    tester,
  ) async {
    await tester.pumpWidget(const UniConnectApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to UniConnect'), findsOneWidget);
    expect(find.text('Your timetable'), findsOneWidget);
  });
}
