import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/features/auth/presentation/cubit/login_cubit.dart';
import 'package:uniconnect/features/auth/presentation/pages/login_page.dart';

class MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

void main() {
  late MockLoginCubit cubit;

  setUp(() {
    cubit = MockLoginCubit();
    when(
      () => cubit.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() => getIt.reset());

  Finder emailField() => find.widgetWithText(TextField, 'Email');
  Finder passwordField() => find.widgetWithText(TextField, 'Password');
  Finder signInButton() => find.byType(FilledButton);

  Future<void> pumpLoginView(
    WidgetTester tester,
    LoginState state, {
    String? sessionErrorMessage,
  }) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginCubit>.value(
          value: cubit,
          child: LoginView(sessionErrorMessage: sessionErrorMessage),
        ),
      ),
    );
  }

  testWidgets('shows the email and password fields and the button', (
    tester,
  ) async {
    await pumpLoginView(tester, const LoginInitial());

    expect(emailField(), findsOneWidget);
    expect(passwordField(), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('hides the password until the user asks to show it', (
    tester,
  ) async {
    await pumpLoginView(tester, const LoginInitial());

    TextField password() => tester.widget<TextField>(passwordField());
    expect(password().obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(password().obscureText, isFalse);
  });

  testWidgets('signs in with the email and password typed by the user', (
    tester,
  ) async {
    await pumpLoginView(tester, const LoginInitial());

    await tester.enterText(emailField(), 'student@foi.hr');
    await tester.enterText(passwordField(), 'secret');
    await tester.tap(signInButton());

    verify(
      () => cubit.signIn(email: 'student@foi.hr', password: 'secret'),
    ).called(1);
  });

  testWidgets('submitting the password field also signs in', (tester) async {
    await pumpLoginView(tester, const LoginInitial());

    await tester.enterText(emailField(), 'student@foi.hr');
    await tester.enterText(passwordField(), 'secret');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    verify(
      () => cubit.signIn(email: 'student@foi.hr', password: 'secret'),
    ).called(1);
  });

  for (final busy in const <LoginState>[LoginSubmitting(), LoginSuccess()]) {
    testWidgets('shows progress and disables the form in ${busy.runtimeType}', (
      tester,
    ) async {
      await pumpLoginView(tester, busy);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<FilledButton>(signInButton()).onPressed, isNull);
      expect(tester.widget<TextField>(emailField()).enabled, isFalse);
      expect(tester.widget<TextField>(passwordField()).enabled, isFalse);
    });
  }

  testWidgets('shows the failure message', (tester) async {
    await pumpLoginView(
      tester,
      const LoginFailure('Incorrect email or password.'),
    );

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(tester.widget<FilledButton>(signInButton()).onPressed, isNotNull);
  });

  testWidgets('shows why the session ended until the next attempt', (
    tester,
  ) async {
    await pumpLoginView(
      tester,
      const LoginInitial(),
      sessionErrorMessage: 'Your profile could not be found.',
    );

    expect(find.text('Your profile could not be found.'), findsOneWidget);
  });

  testWidgets('the failure message replaces the session message', (
    tester,
  ) async {
    await pumpLoginView(
      tester,
      const LoginFailure('Incorrect email or password.'),
      sessionErrorMessage: 'Your profile could not be found.',
    );

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('Your profile could not be found.'), findsNothing);
  });

  testWidgets('LoginPage gets its cubit from get_it', (tester) async {
    when(() => cubit.state).thenReturn(const LoginInitial());
    getIt.registerFactory<LoginCubit>(() => cubit);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
