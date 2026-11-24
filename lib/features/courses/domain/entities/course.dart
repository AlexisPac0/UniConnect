import 'package:equatable/equatable.dart';

/// A course of the university catalogue, managed by administrators (UC1).
class Course extends Equatable {
  const Course({
    required this.id,
    required this.name,
    required this.code,
    required this.semester,
  });

  /// Id of the Firestore document `courses/{id}`.
  final String id;

  /// Title, e.g. `Mobile Application Development`.
  final String name;

  /// Unique official code, in upper case, e.g. `CS302`.
  final String code;

  /// Academic session, e.g. `2026-FALL`.
  final String semester;

  Course copyWith({String? name, String? code, String? semester}) {
    return Course(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      semester: semester ?? this.semester,
    );
  }

  @override
  List<Object?> get props => [id, name, code, semester];
}
