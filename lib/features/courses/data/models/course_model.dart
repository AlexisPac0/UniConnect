import 'package:uniconnect/features/courses/domain/entities/course.dart';

class CourseModel {
  const CourseModel({
    required this.name,
    required this.code,
    required this.semester,
  });

  final String name;
  final String code;
  final String semester;

  Course toEntity() {
    return Course(name: name, code: code, semester: semester);
  }
}
