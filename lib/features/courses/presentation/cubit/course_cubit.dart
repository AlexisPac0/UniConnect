import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';
import 'package:uniconnect/features/courses/domain/usecases/delete_course.dart';
import 'package:uniconnect/features/courses/domain/usecases/get_courses.dart';
import 'package:uniconnect/features/courses/domain/usecases/suspend_course.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit(
    this._createCourse, [
    this._getCourses,
    this._suspendCourse,
    this._deleteCourse,
  ]) : super(const CourseInitial());

  final CreateCourse _createCourse;
  final GetCourses? _getCourses;
  final SuspendCourse? _suspendCourse;
  final DeleteCourse? _deleteCourse;

  Future<void> load() async {
    final getCourses = _getCourses;
    if (getCourses == null) return;
    emit(const CourseLoading());
    final result = await getCourses(const NoParams());
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => CourseLoaded(value),
      Failure(:final failure) => CourseError(failure.message),
    });
  }

  Future<void> create({
    required String name,
    required String code,
    required String semester,
  }) async {
    emit(const CourseCreating());
    final result = await _createCourse(
      CreateCourseParams(name: name, code: code, semester: semester),
    );
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => CourseCreated(value),
      Failure(:final failure) => CourseError(failure.message),
    });
  }

  Future<void> suspend(Course course) async {
    final suspendCourse = _suspendCourse;
    if (suspendCourse == null) return;
    emit(CourseUpdating(List<Course>.from(_courses)));
    final result = await suspendCourse(
      SuspendCourseParams(code: course.code, isSuspended: !course.isSuspended),
    );
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => CourseLoaded(_coursesWith(value, replace: true)),
      Failure(:final failure) => CourseError(failure.message),
    });
  }

  Future<void> delete(Course course) async {
    final deleteCourse = _deleteCourse;
    if (deleteCourse == null) return;
    emit(CourseUpdating(List<Course>.from(_courses)));
    final result = await deleteCourse(DeleteCourseParams(course.code));
    if (isClosed) return;
    emit(switch (result) {
      Success() => CourseLoaded(
        _courses.where((item) => item.code != course.code).toList(),
      ),
      Failure(:final failure) => CourseError(failure.message),
    });
  }

  List<Course> get _courses {
    final state = this.state;
    return switch (state) {
      CourseLoaded(:final courses) => courses,
      CourseCreating() => const [],
      CourseCreated(:final courses) => courses,
      CourseUpdating(:final courses) => courses,
      CourseInitial() => const [],
      CourseLoading() => const [],
      CourseError(:final courses) => courses,
    };
  }

  List<Course> _coursesWith(Course course, {bool replace = false}) {
    final courses = List<Course>.from(_courses);
    final index = courses.indexWhere((item) => item.code == course.code);
    if (index >= 0 && replace) {
      courses[index] = course;
    } else if (index == -1) {
      courses.add(course);
    }
    return courses;
  }
}
