import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';

/// Lists all the courses, sorted by name.
class GetCourses extends UseCase<List<Course>, NoParams> {
  const GetCourses(this._repository);

  final CourseRepository _repository;

  @override
  Future<Result<List<Course>>> call(NoParams params) {
    return _repository.getCourses();
  }
}
