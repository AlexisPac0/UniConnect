import 'package:equatable/equatable.dart';
import 'package:uniconnect/core/error/failure.dart';

/// Outcome of an operation that can fail: either a [Success] holding a value
/// or a [Failure] holding an [AppFailure].
///
/// Repositories and use cases return `Future<Result<T>>` instead of throwing.
/// Because the class is sealed, a `switch` on a [Result] is exhaustive:
///
/// ```dart
/// switch (result) {
///   case Success(:final value): ...
///   case Failure(:final failure): ...
/// }
/// ```
sealed class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is Failure<T>;

  /// Maps both cases to a single value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failure<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
