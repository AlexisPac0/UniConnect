import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_out.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SignOut useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignOut(repository);
  });

  test('signs out through the repository', () async {
    when(
      () => repository.signOut(),
    ).thenAnswer((_) async => const Success<void>(null));

    final result = await useCase(const NoParams());

    expect(result, const Success<void>(null));
    verify(() => repository.signOut()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('forwards the failure of the repository', () async {
    const failure = UnexpectedFailure(message: 'Could not log you out.');
    when(
      () => repository.signOut(),
    ).thenAnswer((_) async => const Failure<void>(failure));

    final result = await useCase(const NoParams());

    expect(result, const Failure<void>(failure));
  });
}
