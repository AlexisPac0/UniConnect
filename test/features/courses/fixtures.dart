import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';

const tAlgorithms = Course(
  id: 'c1',
  name: 'Algorithms',
  code: 'ALG201',
  semester: '2026-FALL',
);

const tMobile = Course(
  id: 'c2',
  name: 'Mobile Development',
  code: 'CS302',
  semester: '2026-FALL',
);

const tDatabases = Course(
  id: 'c3',
  name: 'Databases',
  code: 'DB101',
  semester: '2026-SPRING',
);

/// Values as typed in the form: spaces around and a lower-case code.
const tTypedDatabases = CourseParams(
  name: '  Databases ',
  code: ' db101 ',
  semester: '2026-SPRING ',
);
