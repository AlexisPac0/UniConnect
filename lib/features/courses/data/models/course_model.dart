import 'package:uniconnect/features/courses/domain/entities/course.dart';

class CourseModel {
  const CourseModel({
    this.id,
    required this.name,
    required this.code,
    required this.semester,
    this.isSuspended = false,
  });

  final String? id;
  final String name;
  final String code;
  final String semester;
  final bool isSuspended;

  Course toEntity() {
    return Course(
      id: id,
      name: name,
      code: code,
      semester: semester,
      isSuspended: isSuspended,
    );
  }
}
