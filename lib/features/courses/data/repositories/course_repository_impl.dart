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

  @override
  Future<Result<List<Course>>> getCourses() async {
    try {
      final models = await _dataSource.getCourses();
      return Success(models.map((model) => model.toEntity()).toList());
    } catch (error) {
      return Failure(
        UnexpectedFailure(
          message: 'Could not load the courses. Please try again.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<Course>> suspendCourse({
    required String code,
    required bool isSuspended,
  }) async {
    try {
      final model = await _dataSource.suspendCourse(
        code: code,
        isSuspended: isSuspended,
      );
      return Success(model.toEntity());
    } catch (error) {
      return Failure(
        UnexpectedFailure(
          message: 'Could not update the course. Please try again.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteCourse({required String code}) async {
    try {
      await _dataSource.deleteCourse(code: code);
      return const Success(null);
    } catch (error) {
      return Failure(
        UnexpectedFailure(
          message: 'Could not delete the course. Please try again.',
          cause: error,
        ),
      );
    }
  }
}
