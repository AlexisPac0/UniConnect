import 'dart:async';

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

  group('authStateChanges', () {
    test('forwards the users and null given by the data source', () {
      when(
        () => dataSource.authStateChanges(),
      ).thenAnswer((_) => Stream.fromIterable(const [tUser, null]));

      expect(
        repository.authStateChanges(),
        emitsInOrder([tUser, null, emitsDone]),
      );
    });

    test(
      'an error in the stream is emitted as null and the stream goes on',
      () {
        final controller = StreamController<AuthUser?>();
        addTearDown(controller.close);
        when(
          () => dataSource.authStateChanges(),
        ).thenAnswer((_) => controller.stream);

        expect(
          repository.authStateChanges(),
          emitsInOrder(const [tUser, null, tUser]),
        );

        controller
          ..add(tUser)
          ..addError(FirebaseAuthException(code: 'network-request-failed'))
          ..add(tUser);
      },
    );

    test('an error when subscribing is emitted as null', () {
      when(() => dataSource.authStateChanges()).thenThrow(StateError('boom'));

      expect(repository.authStateChanges(), emitsInOrder([isNull, emitsDone]));
    });
  });

  group('signOut', () {
    test('returns a Success when the data source signs out', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Success<void>(null));
      verify(() => dataSource.signOut()).called(1);
    });

    for (final error in <Object>[
      FirebaseAuthException(code: 'network-request-failed'),
      Exception('boom'),
      StateError('boom'),
    ]) {
      test('returns an UnexpectedFailure on ${error.runtimeType}', () async {
        when(() => dataSource.signOut()).thenThrow(error);

        final result = await repository.signOut();

        expect(result, isA<Failure<void>>());
        final failure = (result as Failure<void>).failure;
        expect(failure, isA<UnexpectedFailure>());
        expect(failure.message, 'Could not log you out. Please try again.');
        expect((failure as UnexpectedFailure).cause, same(error));
      });
    }
  });
}
