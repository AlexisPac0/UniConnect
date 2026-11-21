import 'package:firebase_core/firebase_core.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/profile/data/datasources/user_profile_data_source.dart';
import 'package:uniconnect/features/profile/data/models/user_profile_model.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';
import 'package:uniconnect/features/profile/domain/failures/profile_failures.dart';
import 'package:uniconnect/features/profile/domain/repositories/user_profile_repository.dart';

/// [UserProfileRepository] backed by a [UserProfileDataSource].
///
/// Converts models into entities and every thrown error into a `Failure`:
/// - missing document: [ProfileNotFoundFailure];
/// - missing or unknown role: [InvalidRoleFailure];
/// - Firestore `unavailable`: [NetworkFailure];
/// - Firestore `permission-denied`: [PermissionFailure];
/// - anything else: [UnexpectedFailure].
class UserProfileRepositoryImpl implements UserProfileRepository {
  const UserProfileRepositoryImpl(this._dataSource);

  final UserProfileDataSource _dataSource;

  @override
  Future<Result<UserProfile>> getUserProfile(String userId) async {
    try {
      final model = await _dataSource.getUserProfile(userId);
      if (model == null) return const Failure(ProfileNotFoundFailure());
      return Success(model.toEntity());
    } on InvalidRoleException {
      return const Failure(InvalidRoleFailure());
    } on FirebaseException catch (error) {
      return Failure(switch (error.code) {
        'unavailable' => const NetworkFailure(),
        'permission-denied' => const PermissionFailure(),
        _ => _unexpected(error),
      });
    } catch (error) {
      return Failure(_unexpected(error));
    }
  }

  AppFailure _unexpected(Object error) {
    return UnexpectedFailure(
      message: 'Could not load your profile. Please try again.',
      cause: error,
    );
  }
}
