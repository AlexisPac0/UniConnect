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
  const CourseCreated(this.course, {this.courses = const []});

  final Course course;
  final List<Course> courses;

  @override
  List<Object?> get props => [course, courses];
}

final class CourseLoading extends CourseState {
  const CourseLoading();
}

final class CourseLoaded extends CourseState {
  const CourseLoaded(this.courses);

  final List<Course> courses;

  @override
  List<Object?> get props => [courses];
}

final class CourseUpdating extends CourseState {
  const CourseUpdating(this.courses);

  final List<Course> courses;

  @override
  List<Object?> get props => [courses];
}

final class CourseError extends CourseState {
  const CourseError(this.message, {this.courses = const []});

  final String message;
  final List<Course> courses;

  @override
  List<Object?> get props => [message, courses];
}
