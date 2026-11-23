import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/failures/auth_failures.dart';
import 'package:uniconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_in_with_email.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const tUser = AuthUser(id: 'uid-1', email: 'student@foi.hr');

  late MockAuthRepository repository;
  late SignInWithEmail useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignInWithEmail(repository);
  });

  test('returns the signed-in user and trims the email', () async {
    when(
      () => repository.signInWithEmail(
        email: 'student@foi.hr',
        password: 'secret',
      ),
    ).thenAnswer((_) async => const Success(tUser));

    final result = await useCase(
      const SignInParams(email: '  student@foi.hr ', password: 'secret'),
    );

    expect(result, const Success(tUser));
    verify(
      () => repository.signInWithEmail(
        email: 'student@foi.hr',
        password: 'secret',
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('forwards the failure returned by the repository', () async {
    when(
      () => repository.signInWithEmail(
        email: 'student@foi.hr',
        password: 'wrong',
      ),
    ).thenAnswer((_) async => const Failure(InvalidCredentialsFailure()));

    final result = await useCase(
      const SignInParams(email: 'student@foi.hr', password: 'wrong'),
    );

    expect(result, const Failure<AuthUser>(InvalidCredentialsFailure()));
  });

  test('rejects empty fields without calling the repository', () async {
    final result = await useCase(
      const SignInParams(email: '   ', password: ''),
    );

    expect(result.isFailure, isTrue);
    final failure = (result as Failure<AuthUser>).failure;
    expect(failure, isA<InvalidCredentialsFailure>());
    verifyNoMoreInteractions(repository);
  });

  test('does not hide other failures', () async {
    when(
      () => repository.signInWithEmail(
        email: 'student@foi.hr',
        password: 'secret',
      ),
    ).thenAnswer((_) async => const Failure(NetworkFailure()));

    final result = await useCase(
      const SignInParams(email: 'student@foi.hr', password: 'secret'),
    );

    expect(result, const Failure<AuthUser>(NetworkFailure()));
  });
}
