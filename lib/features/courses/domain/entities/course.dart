import 'package:equatable/equatable.dart';

class Course extends Equatable {
  const Course({
    required this.name,
    required this.code,
    required this.semester,
    this.isSuspended = false,
  });

  final String name;
  final String code;
  final String semester;
  final bool isSuspended;

  @override
  List<Object?> get props => [name, code, semester, isSuspended];
}
