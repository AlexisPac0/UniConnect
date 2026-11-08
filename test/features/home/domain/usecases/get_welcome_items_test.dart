import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';
import 'package:uniconnect/features/home/domain/repositories/home_repository.dart';
import 'package:uniconnect/features/home/domain/usecases/get_welcome_items.dart';

import '../../fixtures.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository repository;
  late GetWelcomeItems useCase;

  setUp(() {
    repository = MockHomeRepository();
    useCase = GetWelcomeItems(repository);
  });

  test('returns the welcome items of the given role', () async {
    when(
      () => repository.getWelcomeItems(UserRole.professor),
    ).thenAnswer((_) async => const Success(tWelcomeItems));

    final result = await useCase(UserRole.professor);

    expect(result, const Success(tWelcomeItems));
    verify(() => repository.getWelcomeItems(UserRole.professor)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('forwards the failure returned by the repository', () async {
    when(
      () => repository.getWelcomeItems(UserRole.student),
    ).thenAnswer((_) async => const Failure(NetworkFailure()));

    final result = await useCase(UserRole.student);

    expect(result, const Failure<List<WelcomeItem>>(NetworkFailure()));
  });
}
