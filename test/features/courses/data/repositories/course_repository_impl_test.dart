import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/data/datasources/course_data_source.dart';
import 'package:uniconnect/features/courses/data/models/course_model.dart';
import 'package:uniconnect/features/courses/data/repositories/course_repository_impl.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/failures/course_failures.dart';

import '../../fixtures.dart';

class MockCourseDataSource extends Mock implements CourseDataSource {}

void main() {
  late MockCourseDataSource dataSource;
  late CourseRepositoryImpl repository;

  const algorithmsModel = CourseModel(
    id: 'c1',
    name: 'Algorithms',
    code: 'ALG201',
    semester: '2026-FALL',
  );

  setUpAll(() => registerFallbackValue(algorithmsModel));

  setUp(() {
    dataSource = MockCourseDataSource();
    repository = CourseRepositoryImpl(dataSource);
  });

  FirebaseException firebaseError(String code) =>
      FirebaseException(plugin: 'cloud_firestore', code: code);

  test('getCourses maps the models to entities', () async {
    when(
      () => dataSource.getCourses(),
    ).thenAnswer((_) async => [algorithmsModel]);

    expect(await repository.getCourses(), const Success([tAlgorithms]));
  });

  test('createCourse returns the created course', () async {
    when(
      () => dataSource.createCourse(
        name: 'Algorithms',
        code: 'ALG201',
        semester: '2026-FALL',
      ),
    ).thenAnswer((_) async => algorithmsModel);

    final result = await repository.createCourse(
      name: 'Algorithms',
      code: 'ALG201',
      semester: '2026-FALL',
    );

    expect(result, const Success(tAlgorithms));
  });

  test('updateCourse sends the course to the data source', () async {
    when(() => dataSource.updateCourse(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as CourseModel,
    );

    final result = await repository.updateCourse(tAlgorithms);

    expect(result, const Success(tAlgorithms));
    final sent =
        verify(() => dataSource.updateCourse(captureAny())).captured.single
            as CourseModel;
    expect(sent.toEntity(), tAlgorithms);
  });

  test('deleteCourse deletes by id', () async {
    when(() => dataSource.deleteCourse('c1')).thenAnswer((_) async {});

    expect(await repository.deleteCourse('c1'), const Success<void>(null));
  });

  group('errors', () {
    Future<AppFailure> updateFailureFor(Object error) async {
      when(() => dataSource.updateCourse(any())).thenThrow(error);
      final result = await repository.updateCourse(tAlgorithms);
      return (result as Failure<Course>).failure;
    }

    test('a taken code returns a CourseCodeTakenFailure', () async {
      expect(
        await updateFailureFor(const CourseCodeTakenException('ALG201')),
        const CourseCodeTakenFailure(),
      );
    });

    test('Firestore errors are mapped', () async {
      expect(
        await updateFailureFor(firebaseError('unavailable')),
        const NetworkFailure(),
      );
      expect(
        await updateFailureFor(firebaseError('permission-denied')),
        const PermissionFailure(),
      );
      expect(
        await updateFailureFor(firebaseError('not-found')),
        isA<NotFoundFailure>(),
      );
    });

    test('anything else returns an UnexpectedFailure with the cause', () async {
      final error = StateError('boom');
      when(() => dataSource.getCourses()).thenThrow(error);

      final result = await repository.getCourses();

      final failure = (result as Failure<List<Course>>).failure;
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, 'Could not load the courses. Please try again.');
      expect((failure as UnexpectedFailure).cause, error);
    });
  });
}
