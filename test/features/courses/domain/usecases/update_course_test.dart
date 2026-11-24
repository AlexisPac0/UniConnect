import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/failures/course_failures.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';
import 'package:uniconnect/features/courses/domain/usecases/update_course.dart';

import '../../fixtures.dart';

class MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  late MockCourseRepository repository;
  late UpdateCourse updateCourse;

  setUp(() {
    repository = MockCourseRepository();
    updateCourse = UpdateCourse(repository);
  });

  test('saves the course with trimmed values and an upper-case code', () async {
    when(
      () => repository.updateCourse(tDatabases),
    ).thenAnswer((_) async => const Success(tDatabases));

    final result = await updateCourse(
      const UpdateCourseParams(id: 'c3', values: tTypedDatabases),
    );

    expect(result, const Success(tDatabases));
  });

  test('an empty field fails without calling the repository', () async {
    final result = await updateCourse(
      const UpdateCourseParams(
        id: 'c3',
        values: CourseParams(name: 'Databases', code: 'DB101', semester: ' '),
      ),
    );

    expect(result, const Failure<Course>(InvalidCourseFailure()));
    verifyZeroInteractions(repository);
  });
}
