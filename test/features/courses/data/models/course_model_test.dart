import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/features/courses/data/models/course_model.dart';

import '../../fixtures.dart';

void main() {
  test('fromMap reads the fields and ignores the others', () {
    final model = CourseModel.fromMap('c1', {
      'name': 'Algorithms',
      'code': 'ALG201',
      'semester': '2026-FALL',
      'professorIds': <String>[],
      'studentCount': 0,
    });

    expect(model.toEntity(), tAlgorithms);
  });

  test('fromMap throws a FormatException when a field is missing', () {
    expect(
      () => CourseModel.fromMap('c1', {'name': 'Algorithms', 'code': 'A1'}),
      throwsFormatException,
    );
  });
}
