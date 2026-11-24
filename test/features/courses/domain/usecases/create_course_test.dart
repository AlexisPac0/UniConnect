import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/failures/course_failures.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';

import '../../fixtures.dart';

class MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  late MockCourseRepository repository;
  late CreateCourse createCourse;

  setUp(() {
    repository = MockCourseRepository();
    createCourse = CreateCourse(repository);
  });

  test(
    'creates the course with trimmed values and an upper-case code',
    () async {
      when(
        () => repository.createCourse(
          name: 'Databases',
          code: 'DB101',
          semester: '2026-SPRING',
        ),
      ).thenAnswer((_) async => const Success(tDatabases));

      final result = await createCourse(tTypedDatabases);

      expect(result, const Success(tDatabases));
    },
  );

  for (final (field, params) in [
    ('name', const CourseParams(name: ' ', code: 'DB101', semester: 'S1')),
    ('code', const CourseParams(name: 'Databases', code: '', semester: 'S1')),
    (
      'semester',
      const CourseParams(name: 'Databases', code: 'DB1', semester: ''),
    ),
  ]) {
    test('an empty $field fails without calling the repository', () async {
      final result = await createCourse(params);

      expect(result, const Failure<Course>(InvalidCourseFailure()));
      verifyZeroInteractions(repository);
    });
  }
}
