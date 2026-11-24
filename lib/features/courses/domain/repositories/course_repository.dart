import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';

/// Access to the course catalogue. Never throws: every error is a `Failure`.
abstract interface class CourseRepository {
  /// All the courses, sorted by name.
  Future<Result<List<Course>>> getCourses();

  /// Creates a course. Fails with `CourseCodeTakenFailure` if the code is
  /// already used.
  Future<Result<Course>> createCourse({
    required String name,
    required String code,
    required String semester,
  });

  /// Saves the name, code and semester of [course]. Fails with
  /// `CourseCodeTakenFailure` if another course uses its code.
  Future<Result<Course>> updateCourse(Course course);

  /// Deletes the course [id] and its enrolments.
  Future<Result<void>> deleteCourse(String id);
}
