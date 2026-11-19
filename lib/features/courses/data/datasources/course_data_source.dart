import 'package:uniconnect/features/courses/data/models/course_model.dart';

abstract interface class CourseDataSource {
  Future<CourseModel> createCourse({
    required String name,
    required String code,
    required String semester,
  });
}

/// Temporary backend substitute until the course API is available.
class FakeCourseDataSource implements CourseDataSource {
  const FakeCourseDataSource();

  @override
  Future<CourseModel> createCourse({
    required String name,
    required String code,
    required String semester,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return CourseModel(
      name: name.trim(),
      code: code.trim().toUpperCase(),
      semester: semester.trim(),
    );
  }
}
