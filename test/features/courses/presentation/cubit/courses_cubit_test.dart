import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/failures/course_failures.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';
import 'package:uniconnect/features/courses/domain/usecases/delete_course.dart';
import 'package:uniconnect/features/courses/domain/usecases/get_courses.dart';
import 'package:uniconnect/features/courses/domain/usecases/update_course.dart';
import 'package:uniconnect/features/courses/presentation/cubit/courses_cubit.dart';

import '../../fixtures.dart';

class MockGetCourses extends Mock implements GetCourses {}

class MockCreateCourse extends Mock implements CreateCourse {}

class MockUpdateCourse extends Mock implements UpdateCourse {}

class MockDeleteCourse extends Mock implements DeleteCourse {}

void main() {
  late MockGetCourses getCourses;
  late MockCreateCourse createCourse;
  late MockUpdateCourse updateCourse;
  late MockDeleteCourse deleteCourse;

  const loaded = CoursesLoaded([tAlgorithms, tMobile]);

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(tTypedDatabases);
    registerFallbackValue(
      const UpdateCourseParams(id: 'c1', values: tTypedDatabases),
    );
  });

  setUp(() {
    getCourses = MockGetCourses();
    createCourse = MockCreateCourse();
    updateCourse = MockUpdateCourse();
    deleteCourse = MockDeleteCourse();
  });

  CoursesCubit buildCubit() => CoursesCubit(
    getCourses: getCourses,
    createCourse: createCourse,
    updateCourse: updateCourse,
    deleteCourse: deleteCourse,
  );

  group('load', () {
    blocTest<CoursesCubit, CoursesState>(
      'emits the loaded courses',
      setUp: () => when(
        () => getCourses(any()),
      ).thenAnswer((_) async => const Success([tAlgorithms, tMobile])),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [const CoursesLoading(), loaded],
    );

    blocTest<CoursesCubit, CoursesState>(
      'emits the error message when loading fails',
      setUp: () => when(
        () => getCourses(any()),
      ).thenAnswer((_) async => const Failure(NetworkFailure())),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const CoursesLoading(),
        CoursesLoadError(const NetworkFailure().message),
      ],
    );
  });

  group('create', () {
    blocTest<CoursesCubit, CoursesState>(
      'adds the course to the list, sorted by name',
      setUp: () => when(
        () => createCourse(any()),
      ).thenAnswer((_) async => const Success(tDatabases)),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) async => expect(await cubit.create(tTypedDatabases), isNull),
      expect: () => [
        const CoursesLoaded([tAlgorithms, tDatabases, tMobile]),
      ],
    );

    blocTest<CoursesCubit, CoursesState>(
      'returns the error and keeps the list on failure',
      setUp: () => when(
        () => createCourse(any()),
      ).thenAnswer((_) async => const Failure(CourseCodeTakenFailure())),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) async => expect(
        await cubit.create(tTypedDatabases),
        const CourseCodeTakenFailure().message,
      ),
      expect: () => <CoursesState>[],
    );
  });

  blocTest<CoursesCubit, CoursesState>(
    'update replaces the course and keeps the list sorted',
    setUp: () => when(() => updateCourse(any())).thenAnswer(
      (_) async => Success(tAlgorithms.copyWith(name: 'Web Development')),
    ),
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) async =>
        expect(await cubit.update('c1', tTypedDatabases), isNull),
    expect: () => [
      CoursesLoaded([tMobile, tAlgorithms.copyWith(name: 'Web Development')]),
    ],
  );

  group('delete', () {
    blocTest<CoursesCubit, CoursesState>(
      'removes the course from the list',
      setUp: () => when(
        () => deleteCourse('c1'),
      ).thenAnswer((_) async => const Success(null)),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) async => expect(await cubit.delete(tAlgorithms), isNull),
      expect: () => [
        const CoursesLoaded([tMobile]),
      ],
    );

    blocTest<CoursesCubit, CoursesState>(
      'returns the error and keeps the list on failure',
      setUp: () => when(
        () => deleteCourse('c1'),
      ).thenAnswer((_) async => const Failure<void>(PermissionFailure())),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) async => expect(
        await cubit.delete(tAlgorithms),
        const PermissionFailure().message,
      ),
      expect: () => <CoursesState>[],
    );
  });

  test('Course equality includes the id', () {
    expect(tAlgorithms == tAlgorithms.copyWith(), isTrue);
    expect(
      tAlgorithms ==
          const Course(
            id: 'other',
            name: 'Algorithms',
            code: 'ALG201',
            semester: '2026-FALL',
          ),
      isFalse,
    );
  });
}
