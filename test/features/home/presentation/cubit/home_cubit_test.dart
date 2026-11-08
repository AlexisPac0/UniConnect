import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/home/domain/usecases/get_welcome_items.dart';
import 'package:uniconnect/features/home/presentation/cubit/home_cubit.dart';

import '../../fixtures.dart';

class MockGetWelcomeItems extends Mock implements GetWelcomeItems {}

void main() {
  late MockGetWelcomeItems getWelcomeItems;

  setUp(() => getWelcomeItems = MockGetWelcomeItems());

  test('initial state is HomeLoading', () {
    expect(HomeCubit(getWelcomeItems).state, const HomeLoading());
  });

  blocTest<HomeCubit, HomeState>(
    'emits [HomeLoading, HomeLoaded] when the items are loaded',
    setUp: () => when(
      () => getWelcomeItems(UserRole.student),
    ).thenAnswer((_) async => const Success(tWelcomeItems)),
    build: () => HomeCubit(getWelcomeItems),
    act: (cubit) => cubit.load(UserRole.student),
    expect: () => const [HomeLoading(), HomeLoaded(tWelcomeItems)],
    verify: (_) => verify(() => getWelcomeItems(UserRole.student)).called(1),
  );

  blocTest<HomeCubit, HomeState>(
    'emits [HomeLoading, HomeError] with the failure message on failure',
    setUp: () => when(
      () => getWelcomeItems(UserRole.professor),
    ).thenAnswer((_) async => const Failure(NetworkFailure())),
    build: () => HomeCubit(getWelcomeItems),
    act: (cubit) => cubit.load(UserRole.professor),
    expect: () => [
      const HomeLoading(),
      HomeError(const NetworkFailure().message),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'goes back to HomeLoading when retrying after an error',
    setUp: () => when(
      () => getWelcomeItems(UserRole.admin),
    ).thenAnswer((_) async => const Success(tWelcomeItems)),
    build: () => HomeCubit(getWelcomeItems),
    seed: () => const HomeError('Boom'),
    act: (cubit) => cubit.load(UserRole.admin),
    expect: () => const [HomeLoading(), HomeLoaded(tWelcomeItems)],
  );
}
