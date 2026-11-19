import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';
import 'package:uniconnect/features/courses/presentation/cubit/course_cubit.dart';

class MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  late MockCourseRepository repository;
  late CourseCubit cubit;

  const course = Course(
    name: 'Algorithms',
    code: 'ALG201',
    semester: 'Winter 2026',
  );

  setUp(() {
    repository = MockCourseRepository();
    cubit = CourseCubit(CreateCourse(repository));
  });

  tearDown(() => cubit.close());

  blocTest<CourseCubit, CourseState>(
    'emits creating then created when the course is created',
    setUp: () {
      when(
        () => repository.createCourse(
          name: 'Algorithms',
          code: 'alg201',
          semester: 'Winter 2026',
        ),
      ).thenAnswer((_) async => const Success(course));
    },
    build: () => cubit,
    act: (cubit) => cubit.create(
      name: 'Algorithms',
      code: 'alg201',
      semester: 'Winter 2026',
    ),
    expect: () => [const CourseCreating(), const CourseCreated(course)],
  );

  blocTest<CourseCubit, CourseState>(
    'emits an error when course creation fails',
    setUp: () {
      when(
        () => repository.createCourse(
          name: 'Algorithms',
          code: 'alg201',
          semester: 'Winter 2026',
        ),
      ).thenAnswer(
        (_) async => const Failure(
          UnexpectedFailure(message: 'Could not create the course.'),
        ),
      );
    },
    build: () => cubit,
    act: (cubit) => cubit.create(
      name: 'Algorithms',
      code: 'alg201',
      semester: 'Winter 2026',
    ),
    expect: () => [
      const CourseCreating(),
      const CourseError('Could not create the course.'),
    ],
  );
}
