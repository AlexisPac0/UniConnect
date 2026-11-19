import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';

abstract interface class CourseRepository {
  Future<Result<Course>> createCourse({
    required String name,
    required String code,
    required String semester,
  });
}
