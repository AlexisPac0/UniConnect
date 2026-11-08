import 'package:equatable/equatable.dart';
import 'package:uniconnect/core/result/result.dart';

/// A single business action of the domain layer.
///
/// [T] is the type of the returned value and [Params] the input. Use cases
/// are callable classes: `final result = await getWelcomeItems(role);`.
abstract class UseCase<T, Params> {
  const UseCase();

  Future<Result<T>> call(Params params);
}

/// Parameter type for use cases that do not need any input.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
