import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/core/router/app_router.dart';
import 'package:uniconnect/core/session/app_session.dart';
import 'package:uniconnect/features/auth/data/datasources/auth_data_source.dart';
import 'package:uniconnect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:uniconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:uniconnect/features/auth/domain/usecases/sign_out.dart';
import 'package:uniconnect/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:uniconnect/features/auth/presentation/cubit/login_cubit.dart';
import 'package:uniconnect/features/auth/presentation/cubit/sign_out_cubit.dart';
import 'package:uniconnect/features/courses/data/datasources/course_data_source.dart';
import 'package:uniconnect/features/courses/data/repositories/course_repository_impl.dart';
import 'package:uniconnect/features/courses/domain/repositories/course_repository.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';
import 'package:uniconnect/features/courses/domain/usecases/delete_course.dart';
import 'package:uniconnect/features/courses/domain/usecases/get_courses.dart';
import 'package:uniconnect/features/courses/domain/usecases/update_course.dart';
import 'package:uniconnect/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:uniconnect/features/home/data/datasources/home_data_source.dart';
import 'package:uniconnect/features/home/data/repositories/home_repository_impl.dart';
import 'package:uniconnect/features/home/domain/repositories/home_repository.dart';
import 'package:uniconnect/features/home/domain/usecases/get_welcome_items.dart';
import 'package:uniconnect/features/home/presentation/cubit/home_cubit.dart';
import 'package:uniconnect/features/profile/data/datasources/user_profile_data_source.dart';
import 'package:uniconnect/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:uniconnect/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:uniconnect/features/profile/domain/usecases/get_user_profile.dart';
import 'package:uniconnect/features/profile/presentation/session/session_controller.dart';

/// Global service locator.
///
/// Every dependency of the app is registered here, in one place, so that the
/// object graph is easy to read and to replace in tests. This file (with
/// `core/router`) is the composition root: it is the only place outside a
/// feature allowed to import that feature's `data` layer.
final GetIt getIt = GetIt.instance;

/// Registers all dependencies. Must be called once before `runApp`.
///
/// Every registration is lazy: nothing is created, and Firebase is not
/// touched, until a dependency is first requested.
void configureDependencies() {
  _registerCore();
  _registerAuthFeature();
  _registerHomeFeature();
  _registerProfileFeature();
  _registerCoursesFeature();
}

void _registerCore() {
  getIt
    ..registerLazySingleton(AppSession.new)
    ..registerLazySingleton<GoRouter>(() => createAppRouter(getIt()));
}

/// Lifetimes:
/// - data sources, repositories and use cases are stateless: lazy singletons;
/// - cubits hold screen state: factories (a new instance per screen).
void _registerAuthFeature() {
  getIt
    ..registerLazySingleton<AuthDataSource>(
      () => FirebaseAuthDataSource(FirebaseAuth.instance),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton(() => SignInWithEmail(getIt()))
    ..registerLazySingleton(() => SignOut(getIt()))
    ..registerLazySingleton(() => WatchAuthState(getIt()))
    ..registerFactory(() => LoginCubit(getIt()))
    ..registerFactory(() => SignOutCubit(getIt()));
}

void _registerHomeFeature() {
  getIt
    ..registerLazySingleton<HomeDataSource>(InMemoryHomeDataSource.new)
    ..registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(getIt()))
    ..registerLazySingleton(() => GetWelcomeItems(getIt()))
    ..registerFactory(() => HomeCubit(getIt()));
}

/// `FirebaseFirestore.instance` is only read the first time the profile is
/// requested. [SessionController] is started by `main`, never by the tests.
void _registerProfileFeature() {
  getIt
    ..registerLazySingleton<UserProfileDataSource>(
      () => FirestoreUserProfileDataSource(FirebaseFirestore.instance),
    )
    ..registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetUserProfile(getIt()))
    ..registerLazySingleton(
      () => SessionController(
        watchAuthState: getIt(),
        getUserProfile: getIt(),
        signOut: getIt(),
        session: getIt(),
      ),
      dispose: (controller) => controller.dispose(),
    );
}

void _registerCoursesFeature() {
  getIt
    ..registerLazySingleton<CourseDataSource>(
      () => FirestoreCourseDataSource(FirebaseFirestore.instance),
    )
    ..registerLazySingleton<CourseRepository>(
      () => CourseRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetCourses(getIt()))
    ..registerLazySingleton(() => CreateCourse(getIt()))
    ..registerLazySingleton(() => UpdateCourse(getIt()))
    ..registerLazySingleton(() => DeleteCourse(getIt()))
    ..registerFactory(
      () => CoursesCubit(
        getCourses: getIt(),
        createCourse: getIt(),
        updateCourse: getIt(),
        deleteCourse: getIt(),
      ),
    );
}
