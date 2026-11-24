import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/failures/course_failures.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';

class UpdateCourseParams {
  const UpdateCourseParams({required this.id, required this.values});

  /// Id of the course to edit.
  final String id;

  /// New name, code and semester.
  final CourseParams values;
}

/// Edits the name, code and semester of a course. Fails with
/// [InvalidCourseFailure] when a field is empty.
class UpdateCourse extends UseCase<Course, UpdateCourseParams> {
  const UpdateCourse(this._repository);

  final CourseRepository _repository;

  @override
  Future<Result<Course>> call(UpdateCourseParams params) async {
    final values = params.values.normalized();
    if (values == null) return const Failure(InvalidCourseFailure());
    return _repository.updateCourse(
      Course(
        id: params.id,
        name: values.name,
        code: values.code,
        semester: values.semester,
      ),
    );
  }
}
