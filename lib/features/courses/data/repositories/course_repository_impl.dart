import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/data/datasources/course_data_source.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  const CourseRepositoryImpl(this._dataSource);

  final CourseDataSource _dataSource;

  @override
  Future<Result<Course>> createCourse({
    required String name,
    required String code,
    required String semester,
  }) async {
    try {
      final model = await _dataSource.createCourse(
        name: name,
        code: code,
        semester: semester,
      );
      return Success(model.toEntity());
    } catch (error) {
      return Failure(
        UnexpectedFailure(
          message: 'Could not create the course. Please try again.',
          cause: error,
        ),
      );
    }
  }
}
