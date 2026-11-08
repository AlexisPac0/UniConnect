import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';

void main() {
  group('Result', () {
    test('Success exposes its value and folds to onSuccess', () {
      const Result<int> result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(
        result.fold(onSuccess: (value) => 'ok $value', onFailure: (_) => 'ko'),
        'ok 42',
      );
    });

    test('Failure exposes its failure and folds to onFailure', () {
      const Result<int> result = Failure(NetworkFailure());

      expect(result.isFailure, isTrue);
      expect(
        result.fold(
          onSuccess: (_) => 'ok',
          onFailure: (failure) => failure.message,
        ),
        const NetworkFailure().message,
      );
    });

    test('results with the same content are equal', () {
      expect(const Success([1, 2]), const Success([1, 2]));
      expect(
        const Failure<int>(NotFoundFailure()),
        const Failure<int>(NotFoundFailure()),
      );
    });

    test('UnexpectedFailure equality ignores the cause', () {
      expect(
        UnexpectedFailure(cause: Exception('a')),
        UnexpectedFailure(cause: Exception('b')),
      );
    });
  });
}
