import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/core/router/app_router.dart';
import 'package:uniconnect/core/session/current_session.dart';
import 'package:uniconnect/features/home/data/datasources/home_data_source.dart';
import 'package:uniconnect/features/home/data/repositories/home_repository_impl.dart';
import 'package:uniconnect/features/home/domain/repositories/home_repository.dart';
import 'package:uniconnect/features/home/domain/usecases/get_welcome_items.dart';
import 'package:uniconnect/features/home/presentation/cubit/home_cubit.dart';

/// Global service locator.
///
/// Every dependency of the app is registered here, in one place, so that the
/// object graph is easy to read and to replace in tests. This file (with
/// `core/router`) is the composition root: it is the only place outside a
/// feature allowed to import that feature's `data` layer.
final GetIt getIt = GetIt.instance;

/// Registers all dependencies. Must be called once before `runApp`.
void configureDependencies() {
  _registerCore();
  _registerHomeFeature();
}

void _registerCore() {
  getIt
    // TODO(SCRUM-25, SCRUM-28): replace with the authentication feature.
    ..registerLazySingleton(CurrentSession.new)
    ..registerLazySingleton<GoRouter>(() => createAppRouter(getIt()));
}

/// Lifetimes:
/// - data sources, repositories and use cases are stateless: lazy singletons;
/// - cubits hold screen state: factories (a new instance per screen).
void _registerHomeFeature() {
  getIt
    ..registerLazySingleton<HomeDataSource>(InMemoryHomeDataSource.new)
    ..registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(getIt()))
    ..registerLazySingleton(() => GetWelcomeItems(getIt()))
    ..registerFactory(() => HomeCubit(getIt()));
}
