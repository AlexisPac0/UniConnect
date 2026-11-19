import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/auth/data/datasources/auth_data_source.dart';
import 'package:uniconnect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/failures/auth_failures.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  const tUser = AuthUser(id: 'uid-1', email: 'student@foi.hr');

  late MockAuthDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = MockAuthDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  void stubThrows(Object error) {
    when(
      () => dataSource.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(error);
  }

  Future<AppFailure> signInFailure() async {
    final result = await repository.signInWithEmail(
      email: 'student@foi.hr',
      password: 'secret',
    );
    expect(result, isA<Failure<AuthUser>>());
    return (result as Failure<AuthUser>).failure;
  }

  test('returns the user given by the data source', () async {
    when(
      () => dataSource.signInWithEmail(
        email: 'student@foi.hr',
        password: 'secret',
      ),
    ).thenAnswer((_) async => tUser);

    final result = await repository.signInWithEmail(
      email: 'student@foi.hr',
      password: 'secret',
    );

    expect(result, const Success(tUser));
  });

  group('maps Firebase error codes', () {
    for (final code in [
      'invalid-credential',
      'invalid-email',
      'user-not-found',
      'wrong-password',
    ]) {
      test('$code to InvalidCredentialsFailure', () async {
        stubThrows(FirebaseAuthException(code: code));

        expect(await signInFailure(), isA<InvalidCredentialsFailure>());
      });
    }

    test('user-disabled to UserDisabledFailure', () async {
      stubThrows(FirebaseAuthException(code: 'user-disabled'));

      expect(await signInFailure(), isA<UserDisabledFailure>());
    });

    test('too-many-requests to TooManyAttemptsFailure', () async {
      stubThrows(FirebaseAuthException(code: 'too-many-requests'));

      expect(await signInFailure(), isA<TooManyAttemptsFailure>());
    });

    test('network-request-failed to NetworkFailure', () async {
      stubThrows(FirebaseAuthException(code: 'network-request-failed'));

      expect(await signInFailure(), isA<NetworkFailure>());
    });

    test('an unknown code to UnexpectedFailure', () async {
      stubThrows(FirebaseAuthException(code: 'internal-error'));

      expect(await signInFailure(), isA<UnexpectedFailure>());
    });
  });

  test('returns a Failure instead of throwing on any other error', () async {
    stubThrows(Exception('boom'));

    final failure = await signInFailure();

    expect(failure, isA<UnexpectedFailure>());
    expect(failure.message, isNotEmpty);
  });
}
