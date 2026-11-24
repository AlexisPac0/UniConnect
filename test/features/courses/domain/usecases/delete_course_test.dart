import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';
import 'package:uniconnect/features/courses/domain/usecases/delete_course.dart';

class MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  test('deletes the course by id', () async {
    final repository = MockCourseRepository();
    when(
      () => repository.deleteCourse('c1'),
    ).thenAnswer((_) async => const Success(null));

    final result = await DeleteCourse(repository)('c1');

    expect(result, const Success<void>(null));
    verify(() => repository.deleteCourse('c1')).called(1);
  });
}
