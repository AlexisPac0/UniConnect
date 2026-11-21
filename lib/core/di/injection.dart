import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/core/router/app_router.dart';
import 'package:uniconnect/core/session/current_session.dart';
import 'package:uniconnect/features/home/data/datasources/home_data_source.dart';
import 'package:uniconnect/features/home/data/repositories/home_repository_impl.dart';
import 'package:uniconnect/features/home/domain/repositories/home_repository.dart';
import 'package:uniconnect/features/home/domain/usecases/get_welcome_items.dart';
import 'package:uniconnect/features/home/presentation/cubit/home_cubit.dart';
import 'package:uniconnect/features/profile/data/datasources/user_profile_data_source.dart';
import 'package:uniconnect/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:uniconnect/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:uniconnect/features/profile/domain/usecases/get_user_profile.dart';

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
  _registerProfileFeature();
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

/// Everything is lazy: `FirebaseFirestore.instance` is only read the first
/// time the profile is requested, so nothing touches Firebase at startup.
void _registerProfileFeature() {
  getIt
    ..registerLazySingleton<UserProfileDataSource>(
      () => FirestoreUserProfileDataSource(FirebaseFirestore.instance),
    )
    ..registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetUserProfile(getIt()));
}
