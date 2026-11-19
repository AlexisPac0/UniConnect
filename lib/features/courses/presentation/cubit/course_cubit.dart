import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit(this._createCourse) : super(const CourseInitial());

  final CreateCourse _createCourse;

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
}
