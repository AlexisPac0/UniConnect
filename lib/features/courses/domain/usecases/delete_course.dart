import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';

class DeleteCourseParams {
  const DeleteCourseParams(this.code);

  final String code;
}

class DeleteCourse extends UseCase<void, DeleteCourseParams> {
  const DeleteCourse(this._repository);

  final CourseRepository _repository;

  @override
  Future<Result<void>> call(DeleteCourseParams params) {
    return _repository.deleteCourse(code: params.code);
  }
}
