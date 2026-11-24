import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniconnect/features/courses/data/models/course_model.dart';

/// Thrown when another course already uses the code.
class CourseCodeTakenException implements Exception {
  const CourseCodeTakenException(this.code);

  final String code;

  @override
  String toString() => 'CourseCodeTakenException: "$code" is already used';
}

/// Low-level access to the courses. Implementations may throw.
abstract interface class CourseDataSource {
  /// All the courses, sorted by name.
  Future<List<CourseModel>> getCourses();

  /// Throws a [CourseCodeTakenException] if [code] is already used.
  Future<CourseModel> createCourse({
    required String name,
    required String code,
    required String semester,
  });

  /// Throws a [CourseCodeTakenException] if another course uses the code.
  Future<CourseModel> updateCourse(CourseModel course);

  Future<void> deleteCourse(String id);
}

/// [CourseDataSource] on the Firestore collections `courses` and
/// `enrolments` (see docs/specs/firestore-data-model.md).
///
/// The code is checked with a query before writing: two administrators
/// saving the same code at the same moment could still both succeed.
class FirestoreCourseDataSource implements CourseDataSource {
  const FirestoreCourseDataSource(this._firestore);

  static const String collection = 'courses';
  static const String enrolments = 'enrolments';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _courses =>
      _firestore.collection(collection);

  @override
  Future<List<CourseModel>> getCourses() async {
    final snapshot = await _courses.orderBy('name').get();
    return [
      for (final document in snapshot.docs)
        CourseModel.fromMap(document.id, document.data()),
    ];
  }

  @override
  Future<CourseModel> createCourse({
    required String name,
    required String code,
    required String semester,
  }) async {
    await _checkCodeIsFree(code);
    final now = FieldValue.serverTimestamp();
    final reference = await _courses.add({
      'code': code,
      'name': name,
      'semester': semester,
      'professorIds': <String>[],
      'studentCount': 0,
      'createdAt': now,
      'updatedAt': now,
    });
    return CourseModel(
      id: reference.id,
      name: name,
      code: code,
      semester: semester,
    );
  }

  /// Also updates the copies of the code and name kept in the enrolments of
  /// the course, in the same batch.
  @override
  Future<CourseModel> updateCourse(CourseModel course) async {
    await _checkCodeIsFree(course.code, exceptId: course.id);
    final batch = _firestore.batch()
      ..update(_courses.doc(course.id), {
        'code': course.code,
        'name': course.name,
        'semester': course.semester,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    for (final enrolment in await _enrolmentsOf(course.id)) {
      batch.update(enrolment.reference, {
        'courseCode': course.code,
        'courseName': course.name,
      });
    }
    await batch.commit();
    return course;
  }

  /// Deletes the course and its enrolments in one batch.
  @override
  Future<void> deleteCourse(String id) async {
    final batch = _firestore.batch()..delete(_courses.doc(id));
    for (final enrolment in await _enrolmentsOf(id)) {
      batch.delete(enrolment.reference);
    }
    await batch.commit();
  }

  Future<void> _checkCodeIsFree(String code, {String? exceptId}) async {
    final snapshot = await _courses
        .where('code', isEqualTo: code)
        .limit(2)
        .get();
    if (snapshot.docs.any((document) => document.id != exceptId)) {
      throw CourseCodeTakenException(code);
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _enrolmentsOf(
    String courseId,
  ) async {
    final snapshot = await _firestore
        .collection(enrolments)
        .where('courseId', isEqualTo: courseId)
        .get();
    return snapshot.docs;
  }
}
