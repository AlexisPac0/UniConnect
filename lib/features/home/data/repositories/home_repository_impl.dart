import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/home/data/datasources/home_data_source.dart';
import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';
import 'package:uniconnect/features/home/domain/repositories/home_repository.dart';

/// [HomeRepository] backed by a [HomeDataSource].
///
/// Converts models into entities and every thrown error into a `Failure`.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._dataSource);

  final HomeDataSource _dataSource;

  @override
  Future<Result<List<WelcomeItem>>> getWelcomeItems(UserRole role) async {
    try {
      final models = await _dataSource.getWelcomeItems(role);
      return Success(models.map((model) => model.toEntity()).toList());
    } catch (error) {
      return Failure(
        UnexpectedFailure(
          message: 'Could not load your home screen. Please try again.',
          cause: error,
        ),
      );
    }
  }
}
