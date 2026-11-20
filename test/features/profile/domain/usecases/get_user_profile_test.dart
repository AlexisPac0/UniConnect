import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';
import 'package:uniconnect/features/profile/domain/failures/profile_failures.dart';
import 'package:uniconnect/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:uniconnect/features/profile/domain/usecases/get_user_profile.dart';

import '../../fixtures.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late MockUserProfileRepository repository;
  late GetUserProfile useCase;

  setUp(() {
    repository = MockUserProfileRepository();
    useCase = GetUserProfile(repository);
  });

  test('returns the profile of the given user', () async {
    when(
      () => repository.getUserProfile(tUserId),
    ).thenAnswer((_) async => const Success(tStudentProfile));

    final result = await useCase(tUserId);

    expect(result, const Success(tStudentProfile));
    verify(() => repository.getUserProfile(tUserId)).called(1);
    verifyNoMoreInteractions(repository);
  });

  for (final failure in const <AppFailure>[
    ProfileNotFoundFailure(),
    InvalidRoleFailure(),
    NetworkFailure(),
  ]) {
    test('forwards a ${failure.runtimeType} from the repository', () async {
      when(
        () => repository.getUserProfile(tUserId),
      ).thenAnswer((_) async => Failure(failure));

      final result = await useCase(tUserId);

      expect(result, Failure<UserProfile>(failure));
    });
  }

  for (final userId in ['', '   ']) {
    test(
      'returns a failure without calling the repository for "$userId"',
      () async {
        final result = await useCase(userId);

        expect(result, const Failure<UserProfile>(ProfileNotFoundFailure()));
        verifyZeroInteractions(repository);
      },
    );
  }
}
