/// Semesters a course can belong to, stored as `<year>-FALL` or
/// `<year>-SPRING` (e.g. `2026-FALL`).
///
/// The fall semester runs from September to January, so January still
/// belongs to the fall semester of the previous year; the spring semester
/// runs from February to August.
abstract final class Semesters {
  /// The semester running on [date].
  static String current(DateTime date) {
    if (date.month >= 9) return '${date.year}-FALL';
    if (date.month == 1) return '${date.year - 1}-FALL';
    return '${date.year}-SPRING';
  }

  /// The semesters of the previous, current and next years, in
  /// chronological order: the choices offered when editing a course.
  static List<String> around(DateTime date) {
    final year = current(date).split('-').first;
    final first = int.parse(year) - 1;
    return [
      for (var y = first; y <= first + 2; y++) ...['$y-SPRING', '$y-FALL'],
    ];
  }
}
