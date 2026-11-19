part of 'course_cubit.dart';

sealed class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

final class CourseInitial extends CourseState {
  const CourseInitial();
}

final class CourseCreating extends CourseState {
  const CourseCreating();
}

final class CourseCreated extends CourseState {
  const CourseCreated(this.course);

  final Course course;

  @override
  List<Object?> get props => [course];
}

final class CourseError extends CourseState {
  const CourseError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
