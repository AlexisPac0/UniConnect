import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';

class SuspendCourseParams {
  const SuspendCourseParams({required this.code, required this.isSuspended});

  final String code;
  final bool isSuspended;
}

class SuspendCourse extends UseCase<Course, SuspendCourseParams> {
  const SuspendCourse(this._repository);

  final CourseRepository _repository;

  @override
  Future<Result<Course>> call(SuspendCourseParams params) {
    return _repository.suspendCourse(
      code: params.code,
      isSuspended: params.isSuspended,
    );
  }
}
