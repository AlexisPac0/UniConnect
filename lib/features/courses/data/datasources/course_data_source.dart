import 'package:uniconnect/features/courses/data/models/course_model.dart';

abstract interface class CourseDataSource {
  Future<CourseModel> createCourse({
    required String name,
    required String code,
    required String semester,
  });
  Future<List<CourseModel>> getCourses();
  Future<CourseModel> suspendCourse({
    required String code,
    required bool isSuspended,
  });
  Future<void> deleteCourse({required String code});
}

/// Temporary backend substitute until the course API is available.
class FakeCourseDataSource implements CourseDataSource {
  const FakeCourseDataSource();

  static final List<CourseModel> _courses = [
    const CourseModel(
      name: 'Algorithms',
      code: 'ALG201',
      semester: 'Winter 2026',
    ),
    const CourseModel(
      name: 'Mobile Development',
      code: 'MOB101',
      semester: 'Summer 2026',
    ),
  ];

  @override
  Future<CourseModel> createCourse({
    required String name,
    required String code,
    required String semester,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final course = CourseModel(
      name: name.trim(),
      code: code.trim().toUpperCase(),
      semester: semester.trim(),
    );
    _courses.add(course);
    return course;
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<CourseModel>.unmodifiable(_courses);
  }

  @override
  Future<CourseModel> suspendCourse({
    required String code,
    required bool isSuspended,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _courses.indexWhere(
      (course) => course.code.toUpperCase() == code.toUpperCase(),
    );
    if (index == -1) throw Exception('Course not found');
    final updated = CourseModel(
      name: _courses[index].name,
      code: _courses[index].code,
      semester: _courses[index].semester,
      isSuspended: isSuspended,
    );
    _courses[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteCourse({required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _courses.removeWhere(
      (course) => course.code.toUpperCase() == code.toUpperCase(),
    );
  }
}
