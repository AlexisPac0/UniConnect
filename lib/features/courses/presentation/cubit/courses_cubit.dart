import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/usecase/usecase.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';
import 'package:uniconnect/features/courses/domain/usecases/delete_course.dart';
import 'package:uniconnect/features/courses/domain/usecases/get_courses.dart';
import 'package:uniconnect/features/courses/domain/usecases/update_course.dart';

part 'courses_state.dart';

/// State of the course management screen (UC1).
///
/// [create], [update] and [delete] return the error message of a failure,
/// or `null` on success, so that the screen can keep a form open or show a
/// message; the list shown stays the same on failure.
class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit({
    required GetCourses getCourses,
    required CreateCourse createCourse,
    required UpdateCourse updateCourse,
    required DeleteCourse deleteCourse,
  }) : _getCourses = getCourses,
       _createCourse = createCourse,
       _updateCourse = updateCourse,
       _deleteCourse = deleteCourse,
       super(const CoursesLoading());

  final GetCourses _getCourses;
  final CreateCourse _createCourse;
  final UpdateCourse _updateCourse;
  final DeleteCourse _deleteCourse;

  Future<void> load() async {
    emit(const CoursesLoading());
    final result = await _getCourses(const NoParams());
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => CoursesLoaded(value),
      Failure(:final failure) => CoursesLoadError(failure.message),
    });
  }

  Future<String?> create(CourseParams values) async {
    final result = await _createCourse(values);
    return _apply(result, (courses, course) => [...courses, course]);
  }

  Future<String?> update(String id, CourseParams values) async {
    final result = await _updateCourse(
      UpdateCourseParams(id: id, values: values),
    );
    return _apply(result, (courses, course) {
      return [for (final item in courses) item.id == id ? course : item];
    });
  }

  Future<String?> delete(Course course) async {
    final result = await _deleteCourse(course.id);
    return _apply(result, (courses, _) {
      return courses.where((item) => item.id != course.id).toList();
    });
  }

  /// On success, emits the list changed by [change], sorted by name.
  String? _apply<T>(
    Result<T> result,
    List<Course> Function(List<Course> courses, T value) change,
  ) {
    switch (result) {
      case Failure(:final failure):
        return failure.message;
      case Success(:final value):
        final state = this.state;
        if (!isClosed && state is CoursesLoaded) {
          final courses = change(state.courses, value)
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
          emit(CoursesLoaded(courses));
        }
        return null;
    }
  }
}
