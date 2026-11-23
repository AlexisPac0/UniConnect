import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniconnect/features/courses/data/models/course_model.dart';

abstract interface class CourseDataSource {
  Future<CourseModel> createCourse({
    required String name,
    required String code,
    required String semester,
  });
  Future<List<CourseModel>> getCourses();
  Future<CourseModel> suspendCourse({
    required String code,
    required bool isSuspended,
  });
  Future<void> deleteCourse({required String code});
}

class FirestoreCourseDataSource implements CourseDataSource {
  FirestoreCourseDataSource([FirebaseFirestore? firestore])
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _courses =>
      _database.collection('courses');

  CourseModel _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return CourseModel(
      id: document.id,
      name: (data['name'] as String?)?.trim() ?? '',
      code: (data['code'] as String?)?.trim().toUpperCase() ?? '',
      semester: (data['semester'] as String?)?.trim() ?? '',
      isSuspended: data['isSuspended'] as bool? ?? false,
    );
  }

  @override
  Future<CourseModel> createCourse({
    required String name,
    required String code,
    required String semester,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final existing = await _courses
        .where('code', isEqualTo: normalizedCode)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'A course with this code already exists.',
      );
    }

    final now = FieldValue.serverTimestamp();
    final reference = await _courses.add({
      'code': normalizedCode,
      'name': name.trim(),
      'semester': semester.trim(),
      'isSuspended': false,
      'professorIds': <String>[],
      'studentCount': 0,
      'createdAt': now,
      'updatedAt': now,
    });
    final document = await reference.get();
    final data = document.data();
    if (data == null) throw StateError('The created course is missing.');
    return CourseModel(
      id: document.id,
      name: (data['name'] as String?)?.trim() ?? name.trim(),
      code: (data['code'] as String?)?.trim().toUpperCase() ?? normalizedCode,
      semester: (data['semester'] as String?)?.trim() ?? semester.trim(),
      isSuspended: data['isSuspended'] as bool? ?? false,
    );
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    final snapshot = await _courses.orderBy('name').get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  @override
  Future<CourseModel> suspendCourse({
    required String code,
    required bool isSuspended,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final snapshot = await _courses
        .where('code', isEqualTo: normalizedCode)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Course not found.',
      );
    }
    final document = snapshot.docs.single;
    await document.reference.update({
      'isSuspended': isSuspended,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final updated = await document.reference.get();
    final data = updated.data();
    if (data == null) throw StateError('The course is missing.');
    return CourseModel(
      id: updated.id,
      name: (data['name'] as String?)?.trim() ?? '',
      code: (data['code'] as String?)?.trim().toUpperCase() ?? normalizedCode,
      semester: (data['semester'] as String?)?.trim() ?? '',
      isSuspended: isSuspended,
    );
  }

  @override
  Future<void> deleteCourse({required String code}) async {
    final normalizedCode = code.trim().toUpperCase();
    final snapshot = await _courses
        .where('code', isEqualTo: normalizedCode)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.single.reference.delete();
  }
}
