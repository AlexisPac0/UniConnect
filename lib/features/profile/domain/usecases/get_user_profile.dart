import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';
import 'package:uniconnect/features/profile/domain/failures/profile_failures.dart';
import 'package:uniconnect/features/profile/domain/repositories/user_profile_repository.dart';

/// Loads the [UserProfile] of the user whose id is given as parameter.
///
/// An empty (or blank) id cannot match any profile: a
/// [ProfileNotFoundFailure] is returned without calling the repository.
class GetUserProfile extends UseCase<UserProfile, String> {
  const GetUserProfile(this._repository);

  final UserProfileRepository _repository;

  @override
  Future<Result<UserProfile>> call(String params) async {
    if (params.trim().isEmpty) {
      return const Failure(ProfileNotFoundFailure());
    }
    return _repository.getUserProfile(params);
  }
}
