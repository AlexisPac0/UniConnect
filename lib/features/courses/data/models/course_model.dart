import 'package:uniconnect/features/courses/domain/entities/course.dart';

class CourseModel {
  const CourseModel({
    required this.name,
    required this.code,
    required this.semester,
    this.isSuspended = false,
  });

  final String name;
  final String code;
  final String semester;
  final bool isSuspended;

  Course toEntity() {
    return Course(
      name: name,
      code: code,
      semester: semester,
      isSuspended: isSuspended,
    );
  }
}
