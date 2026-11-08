import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';
import 'package:uniconnect/features/home/domain/repositories/home_repository.dart';

/// Loads the home screen shortcuts for a given [UserRole].
class GetWelcomeItems extends UseCase<List<WelcomeItem>, UserRole> {
  const GetWelcomeItems(this._repository);

  final HomeRepository _repository;

  @override
  Future<Result<List<WelcomeItem>>> call(UserRole params) {
    return _repository.getWelcomeItems(params);
  }
}
