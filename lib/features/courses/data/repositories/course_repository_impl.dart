import 'package:firebase_core/firebase_core.dart';
import 'package:uniconnect/core/error/failure.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/data/datasources/course_data_source.dart';
import 'package:uniconnect/features/courses/data/models/course_model.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/failures/course_failures.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';

/// [CourseRepository] backed by a [CourseDataSource].
///
/// Converts every thrown error into a `Failure`:
/// - code already used: [CourseCodeTakenFailure];
/// - Firestore `unavailable`: [NetworkFailure];
/// - Firestore `permission-denied`: [PermissionFailure];
/// - Firestore `not-found`: [NotFoundFailure];
/// - anything else: [UnexpectedFailure].
class CourseRepositoryImpl implements CourseRepository {
  const CourseRepositoryImpl(this._dataSource);

  final CourseDataSource _dataSource;

  @override
  Future<Result<List<Course>>> getCourses() {
    return _guard('load the courses', () async {
      final models = await _dataSource.getCourses();
      return [for (final model in models) model.toEntity()];
    });
  }

  @override
  Future<Result<Course>> createCourse({
    required String name,
    required String code,
    required String semester,
  }) {
    return _guard('create the course', () async {
      final model = await _dataSource.createCourse(
        name: name,
        code: code,
        semester: semester,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<Course>> updateCourse(Course course) {
    return _guard('save the course', () async {
      final model = await _dataSource.updateCourse(
        CourseModel(
          id: course.id,
          name: course.name,
          code: course.code,
          semester: course.semester,
        ),
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<void>> deleteCourse(String id) {
    return _guard('delete the course', () => _dataSource.deleteCourse(id));
  }

  /// Runs [action], converting its errors into a `Failure`. [what] completes
  /// the message of an unexpected error: "Could not [what]."
  Future<Result<T>> _guard<T>(String what, Future<T> Function() action) async {
    try {
      return Success(await action());
    } on CourseCodeTakenException {
      return const Failure(CourseCodeTakenFailure());
    } on FirebaseException catch (error) {
      return Failure(switch (error.code) {
        'unavailable' => const NetworkFailure(),
        'permission-denied' => const PermissionFailure(),
        'not-found' => const NotFoundFailure(
          'This course no longer exists. Refresh the list.',
        ),
        _ => _unexpected(what, error),
      });
    } catch (error) {
      return Failure(_unexpected(what, error));
    }
  }

  AppFailure _unexpected(String what, Object error) {
    return UnexpectedFailure(
      message: 'Could not $what. Please try again.',
      cause: error,
    );
  }
}
