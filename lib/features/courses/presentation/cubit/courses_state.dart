part of 'courses_cubit.dart';

sealed class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

final class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

/// The list could not be loaded.
final class CoursesLoadError extends CoursesState {
  const CoursesLoadError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CoursesLoaded extends CoursesState {
  const CoursesLoaded(this.courses);

  /// Sorted by name.
  final List<Course> courses;

  @override
  List<Object?> get props => [courses];
}
