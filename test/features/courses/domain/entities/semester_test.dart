import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/features/courses/domain/entities/semester.dart';

void main() {
  group('current', () {
    test('September to December is the fall semester of the year', () {
      expect(Semesters.current(DateTime(2026, 9)), '2026-FALL');
      expect(Semesters.current(DateTime(2026, 12, 31)), '2026-FALL');
    });

    test('January is still the fall semester of the previous year', () {
      expect(Semesters.current(DateTime(2027, 1, 15)), '2026-FALL');
    });

    test('February to August is the spring semester', () {
      expect(Semesters.current(DateTime(2027, 2)), '2027-SPRING');
      expect(Semesters.current(DateTime(2027, 8, 31)), '2027-SPRING');
    });
  });

  test('around lists the previous, current and next years in order', () {
    expect(Semesters.around(DateTime(2026, 11)), [
      '2025-SPRING',
      '2025-FALL',
      '2026-SPRING',
      '2026-FALL',
      '2027-SPRING',
      '2027-FALL',
    ]);
  });
}
