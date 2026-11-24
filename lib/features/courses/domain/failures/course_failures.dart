import 'package:uniconnect/core/error/failure.dart';

/// A required field of the course (name, code or semester) is empty.
class InvalidCourseFailure extends AppFailure {
  const InvalidCourseFailure([
    super.message = 'A course needs a name, a code and a semester.',
  ]);
}

/// Another course already uses this code.
class CourseCodeTakenFailure extends AppFailure {
  const CourseCodeTakenFailure([
    super.message = 'A course with this code already exists.',
  ]);
}
