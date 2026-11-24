import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';

/// Deletes a course, given its id, and its enrolments.
class DeleteCourse extends UseCase<void, String> {
  const DeleteCourse(this._repository);

  final CourseRepository _repository;

  @override
  Future<Result<void>> call(String courseId) {
    return _repository.deleteCourse(courseId);
  }
}
