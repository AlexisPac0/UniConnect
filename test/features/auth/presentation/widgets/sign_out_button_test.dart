import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/features/auth/presentation/cubit/sign_out_cubit.dart';
import 'package:uniconnect/features/auth/presentation/widgets/sign_out_button.dart';

class MockSignOutCubit extends MockCubit<SignOutState>
    implements SignOutCubit {}

void main() {
  late MockSignOutCubit cubit;

  setUp(() {
    cubit = MockSignOutCubit();
    when(() => cubit.state).thenReturn(const SignOutIdle());
    when(() => cubit.signOut()).thenAnswer((_) async {});
  });

  tearDown(() => getIt.reset());

  Widget appBarWith(Widget button) {
    return MaterialApp(
      home: Scaffold(appBar: AppBar(actions: [button])),
    );
  }

  Future<void> pumpView(WidgetTester tester) async {
    await tester.pumpWidget(
      appBarWith(
        BlocProvider<SignOutCubit>.value(
          value: cubit,
          child: const SignOutButtonView(),
        ),
      ),
    );
  }

  Finder logOutButton() => find.byTooltip('Log out');

  Future<void> openDialog(WidgetTester tester) async {
    await tester.tap(logOutButton());
    await tester.pumpAndSettle();
  }

  testWidgets('shows a log out icon button', (tester) async {
    await pumpView(tester);

    expect(logOutButton(), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('asks for a confirmation', (tester) async {
    await pumpView(tester);

    await openDialog(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Log out?'), findsOneWidget);
    verifyNever(() => cubit.signOut());
  });

  testWidgets('cancel closes the dialog without signing out', (tester) async {
    await pumpView(tester);
    await openDialog(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    verifyNever(() => cubit.signOut());
  });

  testWidgets('dismissing the dialog does not sign out', (tester) async {
    await pumpView(tester);
    await openDialog(tester);

    await tester.tapAt(const Offset(10, 10)); // Outside of the dialog.
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    verifyNever(() => cubit.signOut());
  });

  testWidgets('confirm closes the dialog and signs out', (tester) async {
    await pumpView(tester);
    await openDialog(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    verify(() => cubit.signOut()).called(1);
  });

  testWidgets('shows a SnackBar with the message on error', (tester) async {
    whenListen(
      cubit,
      Stream.fromIterable(const [
        SignOutInProgress(),
        SignOutError('Could not log you out. Please try again.'),
      ]),
      initialState: const SignOutIdle(),
    );

    await pumpView(tester);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Could not log you out. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('is disabled while signing out', (tester) async {
    when(() => cubit.state).thenReturn(const SignOutInProgress());

    await pumpView(tester);

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.logout),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('SignOutButton gets its cubit from get_it', (tester) async {
    getIt.registerFactory<SignOutCubit>(() => cubit);

    await tester.pumpWidget(appBarWith(const SignOutButton()));
    await tester.tap(logOutButton());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    verify(() => cubit.signOut()).called(1);
  });
}
