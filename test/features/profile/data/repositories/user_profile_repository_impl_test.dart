import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/profile/data/datasources/user_profile_data_source.dart';
import 'package:uniconnect/features/profile/data/models/user_profile_model.dart';
import 'package:uniconnect/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:uniconnect/features/profile/domain/entities/user_profile.dart';
import 'package:uniconnect/features/profile/domain/failures/profile_failures.dart';

import '../../fixtures.dart';

class MockUserProfileDataSource extends Mock implements UserProfileDataSource {}

void main() {
  late MockUserProfileDataSource dataSource;
  late UserProfileRepositoryImpl repository;

  setUp(() {
    dataSource = MockUserProfileDataSource();
    repository = UserProfileRepositoryImpl(dataSource);
  });

  FirebaseException firebaseError(String code) =>
      FirebaseException(plugin: 'cloud_firestore', code: code);

  /// Makes the data source throw [error] and returns the resulting failure.
  Future<AppFailure> failureFor(Object error) async {
    when(() => dataSource.getUserProfile(tUserId)).thenThrow(error);

    final result = await repository.getUserProfile(tUserId);

    expect(result, isA<Failure<UserProfile>>());
    return (result as Failure<UserProfile>).failure;
  }

  test('maps the model to the entity', () async {
    when(() => dataSource.getUserProfile(tUserId)).thenAnswer(
      (_) async => const UserProfileModel(
        id: tUserId,
        email: 'jane.doe@university.hr',
        displayName: 'Jane Doe',
        role: UserRole.student,
        studentNumber: '0036512345',
        department: 'Computer Science',
      ),
    );

    final result = await repository.getUserProfile(tUserId);

    expect(result, const Success(tStudentProfile));
    verify(() => dataSource.getUserProfile(tUserId)).called(1);
    verifyNoMoreInteractions(dataSource);
  });

  test('a missing document returns a ProfileNotFoundFailure', () async {
    when(
      () => dataSource.getUserProfile(tUserId),
    ).thenAnswer((_) async => null);

    final result = await repository.getUserProfile(tUserId);

    expect(result, const Failure<UserProfile>(ProfileNotFoundFailure()));
  });

  test('an invalid role returns an InvalidRoleFailure', () async {
    expect(
      await failureFor(const InvalidRoleException('teacher')),
      const InvalidRoleFailure(),
    );
  });

  test('Firestore "unavailable" returns a NetworkFailure', () async {
    expect(
      await failureFor(firebaseError('unavailable')),
      const NetworkFailure(),
    );
  });

  test('Firestore "permission-denied" returns a PermissionFailure', () async {
    expect(
      await failureFor(firebaseError('permission-denied')),
      const PermissionFailure(),
    );
  });

  <String, Object>{
    'another Firestore error': firebaseError('internal'),
    'an invalid document': const FormatException('missing email'),
    'an exception': Exception('backend down'),
    'an error': StateError('unexpected state'),
  }.forEach((label, error) {
    test('$label returns an UnexpectedFailure keeping the cause', () async {
      final failure = await failureFor(error);

      expect(failure, isA<UnexpectedFailure>());
      expect((failure as UnexpectedFailure).cause, same(error));
      expect(failure.message, isNotEmpty);
    });
  });

  test('never throws, whatever the data source throws', () async {
    for (final error in <Object>[
      const InvalidRoleException(null),
      firebaseError('unavailable'),
      firebaseError('permission-denied'),
      firebaseError('internal'),
      const FormatException('invalid'),
      Exception('boom'),
      StateError('boom'),
      'not even an exception',
    ]) {
      when(() => dataSource.getUserProfile(tUserId)).thenThrow(error);

      await expectLater(
        repository.getUserProfile(tUserId),
        completion(isA<Failure<UserProfile>>()),
        reason: '$error',
      );
    }
  });
}
