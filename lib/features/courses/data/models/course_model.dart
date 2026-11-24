import 'package:uniconnect/features/courses/domain/entities/course.dart';

/// Data representation of a [Course], as stored in the Firestore document
/// `courses/{id}`.
class CourseModel {
  const CourseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.semester,
  });

  /// Builds a model from the [id] of the document and its [map] of fields.
  ///
  /// Other fields (`professorIds`, `studentCount`, timestamps...) are
  /// ignored. Throws a [FormatException] if a field is missing or has the
  /// wrong type; the repository converts it into a `Failure`.
  factory CourseModel.fromMap(String id, Map<String, dynamic> map) {
    final name = map['name'];
    final code = map['code'];
    final semester = map['semester'];
    if (name is! String || code is! String || semester is! String) {
      throw FormatException('Invalid course "$id": $map');
    }
    return CourseModel(id: id, name: name, code: code, semester: semester);
  }

  final String id;
  final String name;
  final String code;
  final String semester;

  Course toEntity() {
    return Course(id: id, name: name, code: code, semester: semester);
  }
}
