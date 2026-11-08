part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.items);

  final List<WelcomeItem> items;

  @override
  List<Object?> get props => [items];
}

final class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
