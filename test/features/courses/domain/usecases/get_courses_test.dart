import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';
import 'package:uniconnect/features/courses/domain/usecases/get_courses.dart';

import '../../fixtures.dart';

class MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  test('returns the courses of the repository', () async {
    final repository = MockCourseRepository();
    when(
      () => repository.getCourses(),
    ).thenAnswer((_) async => const Success([tAlgorithms, tMobile]));

    final result = await GetCourses(repository)(const NoParams());

    expect(result, const Success([tAlgorithms, tMobile]));
  });
}
