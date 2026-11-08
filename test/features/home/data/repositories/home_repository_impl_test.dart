import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/home/data/datasources/home_data_source.dart';
import 'package:uniconnect/features/home/data/models/welcome_item_model.dart';
import 'package:uniconnect/features/home/data/repositories/home_repository_impl.dart';
import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';

class MockHomeDataSource extends Mock implements HomeDataSource {}

void main() {
  late MockHomeDataSource dataSource;
  late HomeRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(UserRole.student));

  setUp(() {
    dataSource = MockHomeDataSource();
    repository = HomeRepositoryImpl(dataSource);
  });

  group('with a mocked data source', () {
    test('maps models to entities', () async {
      when(() => dataSource.getWelcomeItems(UserRole.student)).thenAnswer(
        (_) async => const [
          WelcomeItemModel(
            id: '1',
            title: 'Your timetable',
            description: 'Lectures of the week',
            action: 'timetable',
          ),
        ],
      );

      final result = await repository.getWelcomeItems(UserRole.student);

      expect(
        result,
        const Success([
          WelcomeItem(
            id: '1',
            title: 'Your timetable',
            description: 'Lectures of the week',
            action: WelcomeAction.timetable,
          ),
        ]),
      );
    });

    test('returns a Failure instead of throwing', () async {
      when(
        () => dataSource.getWelcomeItems(any()),
      ).thenThrow(Exception('backend down'));

      final result = await repository.getWelcomeItems(UserRole.admin);

      expect(result, isA<Failure<List<WelcomeItem>>>());
      final failure = (result as Failure<List<WelcomeItem>>).failure;
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, isNotEmpty);
    });

    test('returns a Failure when the data is invalid', () async {
      when(() => dataSource.getWelcomeItems(any())).thenAnswer(
        (_) async => const [
          WelcomeItemModel(
            id: '1',
            title: 'Unknown',
            description: 'Unknown action',
            action: 'doesNotExist',
          ),
        ],
      );

      final result = await repository.getWelcomeItems(UserRole.student);

      expect(result.isFailure, isTrue);
    });
  });

  group('with the in-memory data source', () {
    for (final role in UserRole.values) {
      test('returns items for ${role.name}', () async {
        final result = await const HomeRepositoryImpl(
          InMemoryHomeDataSource(),
        ).getWelcomeItems(role);

        expect(result, isA<Success<List<WelcomeItem>>>());
        expect((result as Success<List<WelcomeItem>>).value, isNotEmpty);
      });
    }
  });
}
