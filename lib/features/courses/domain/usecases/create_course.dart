import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/failures/course_failures.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';

/// Name, code and semester of a course, as typed by the administrator.
class CourseParams {
  const CourseParams({
    required this.name,
    required this.code,
    required this.semester,
  });

  final String name;
  final String code;
  final String semester;

  /// Trimmed values, with the code in upper case, or `null` when a field is
  /// empty.
  CourseParams? normalized() {
    final normalized = CourseParams(
      name: name.trim(),
      code: code.trim().toUpperCase(),
      semester: semester.trim(),
    );
    final isComplete =
        normalized.name.isNotEmpty &&
        normalized.code.isNotEmpty &&
        normalized.semester.isNotEmpty;
    return isComplete ? normalized : null;
  }
}

/// Creates a course. Fails with [InvalidCourseFailure] when a field is empty.
class CreateCourse extends UseCase<Course, CourseParams> {
  const CreateCourse(this._repository);

  final CourseRepository _repository;

  @override
  Future<Result<Course>> call(CourseParams params) async {
    final course = params.normalized();
    if (course == null) return const Failure(InvalidCourseFailure());
    return _repository.createCourse(
      name: course.name,
      code: course.code,
      semester: course.semester,
    );
  }
}
