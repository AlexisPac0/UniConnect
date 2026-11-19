import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';

class CreateCourseParams {
  const CreateCourseParams({
    required this.name,
    required this.code,
    required this.semester,
  });

  final String name;
  final String code;
  final String semester;
}

class CreateCourse extends UseCase<Course, CreateCourseParams> {
  const CreateCourse(this._repository);

  final CourseRepository _repository;

  @override
  Future<Result<Course>> call(CreateCourseParams params) {
    return _repository.createCourse(
      name: params.name,
      code: params.code,
      semester: params.semester,
    );
  }
}
