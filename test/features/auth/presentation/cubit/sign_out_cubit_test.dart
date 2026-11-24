import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_out.dart';
import 'package:uniconnect/features/auth/presentation/cubit/sign_out_cubit.dart';

class MockSignOut extends Mock implements SignOut {}

void main() {
  const tFailure = UnexpectedFailure(
    message: 'Could not log you out. Please try again.',
  );

  late MockSignOut signOut;

  setUp(() => signOut = MockSignOut());

  test('initial state is SignOutIdle', () {
    expect(SignOutCubit(signOut).state, const SignOutIdle());
  });

  blocTest<SignOutCubit, SignOutState>(
    'emits [SignOutInProgress, SignOutIdle] when signed out',
    setUp: () => when(
      () => signOut(const NoParams()),
    ).thenAnswer((_) async => const Success<void>(null)),
    build: () => SignOutCubit(signOut),
    act: (cubit) => cubit.signOut(),
    expect: () => const [SignOutInProgress(), SignOutIdle()],
    verify: (_) => verify(() => signOut(const NoParams())).called(1),
  );

  blocTest<SignOutCubit, SignOutState>(
    'emits [SignOutInProgress, SignOutError] with the failure message',
    setUp: () => when(
      () => signOut(const NoParams()),
    ).thenAnswer((_) async => const Failure<void>(tFailure)),
    build: () => SignOutCubit(signOut),
    act: (cubit) => cubit.signOut(),
    expect: () => [const SignOutInProgress(), SignOutError(tFailure.message)],
  );

  blocTest<SignOutCubit, SignOutState>(
    'can retry after an error',
    setUp: () => when(
      () => signOut(const NoParams()),
    ).thenAnswer((_) async => const Success<void>(null)),
    build: () => SignOutCubit(signOut),
    seed: () => const SignOutError('Boom'),
    act: (cubit) => cubit.signOut(),
    expect: () => const [SignOutInProgress(), SignOutIdle()],
  );

  blocTest<SignOutCubit, SignOutState>(
    'ignores a second call while signing out',
    setUp: () {
      final result = Completer<Result<void>>();
      when(() => signOut(const NoParams())).thenAnswer((_) => result.future);
      addTearDown(() => result.complete(const Success<void>(null)));
    },
    build: () => SignOutCubit(signOut),
    act: (cubit) => cubit
      ..signOut()
      ..signOut(),
    expect: () => const [SignOutInProgress()],
    verify: (_) => verify(() => signOut(const NoParams())).called(1),
  );

  test('emits nothing once closed', () async {
    final result = Completer<Result<void>>();
    when(() => signOut(const NoParams())).thenAnswer((_) => result.future);
    final cubit = SignOutCubit(signOut);

    final signingOut = cubit.signOut();
    await cubit.close();
    result.complete(const Success<void>(null));

    await expectLater(signingOut, completes);
  });
}
