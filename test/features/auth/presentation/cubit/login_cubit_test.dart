import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/failures/auth_failures.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:uniconnect/features/auth/presentation/cubit/login_cubit.dart';

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

void main() {
  const tParams = SignInParams(email: 'student@foi.hr', password: 'secret');
  const tUser = AuthUser(id: 'uid-1', email: 'student@foi.hr');

  late MockSignInWithEmail signInWithEmail;

  setUpAll(() => registerFallbackValue(tParams));

  setUp(() => signInWithEmail = MockSignInWithEmail());

  test('initial state is LoginInitial', () {
    expect(LoginCubit(signInWithEmail).state, const LoginInitial());
  });

  blocTest<LoginCubit, LoginState>(
    'emits [LoginSubmitting, LoginSuccess] when the sign-in succeeds',
    setUp: () => when(
      () => signInWithEmail(tParams),
    ).thenAnswer((_) async => const Success(tUser)),
    build: () => LoginCubit(signInWithEmail),
    act: (cubit) => cubit.signIn(email: 'student@foi.hr', password: 'secret'),
    expect: () => const [LoginSubmitting(), LoginSuccess()],
    verify: (_) => verify(() => signInWithEmail(tParams)).called(1),
  );

  blocTest<LoginCubit, LoginState>(
    'emits [LoginSubmitting, LoginFailure] with the failure message',
    setUp: () => when(
      () => signInWithEmail(tParams),
    ).thenAnswer((_) async => const Failure(InvalidCredentialsFailure())),
    build: () => LoginCubit(signInWithEmail),
    act: (cubit) => cubit.signIn(email: 'student@foi.hr', password: 'secret'),
    expect: () => [
      const LoginSubmitting(),
      LoginFailure(const InvalidCredentialsFailure().message),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'can try again after a failure',
    setUp: () => when(
      () => signInWithEmail(tParams),
    ).thenAnswer((_) async => const Failure(NetworkFailure())),
    build: () => LoginCubit(signInWithEmail),
    seed: () => const LoginFailure('Incorrect email or password.'),
    act: (cubit) => cubit.signIn(email: 'student@foi.hr', password: 'secret'),
    expect: () => [
      const LoginSubmitting(),
      LoginFailure(const NetworkFailure().message),
    ],
  );

  for (final busy in const <LoginState>[LoginSubmitting(), LoginSuccess()]) {
    blocTest<LoginCubit, LoginState>(
      'ignores a new attempt while in ${busy.runtimeType}',
      build: () => LoginCubit(signInWithEmail),
      seed: () => busy,
      act: (cubit) => cubit.signIn(email: 'student@foi.hr', password: 'secret'),
      expect: () => const <LoginState>[],
      verify: (_) => verifyNever(() => signInWithEmail(any())),
    );
  }
}
