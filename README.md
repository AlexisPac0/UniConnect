# UniConnect

UniConnect is a Flutter mobile app (Android and iOS) for university
**students**, **professors** and **administrators**. It is built around two
modules:

- **Timetable**: courses, lectures and sessions, a personal schedule and
  notifications when a session changes.
- **Attendance**: lecture check-in with a QR code and geolocation, plus
  attendance statistics.

The backend will be **Firebase** (Authentication, Cloud Firestore, Cloud
Messaging). It is not integrated yet (SCRUM-13); data comes from in-memory
data sources until then.

## Tech stack

| Concern | Choice |
| --- | --- |
| UI | Flutter (Material 3) |
| State management | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (Cubit) |
| Navigation | [`go_router`](https://pub.dev/packages/go_router) |
| Dependency injection | [`get_it`](https://pub.dev/packages/get_it) |
| Value equality | [`equatable`](https://pub.dev/packages/equatable) |
| Tests | `flutter_test`, [`mocktail`](https://pub.dev/packages/mocktail), [`bloc_test`](https://pub.dev/packages/bloc_test) |
| Backend | Firebase via FlutterFire: Authentication, Cloud Firestore, Cloud Functions, Cloud Messaging |

## Architecture

The code is organised **by feature**, and every feature is split into three
layers:

```
lib/features/<feature>/
├── domain/        # Pure Dart: entities, repository interfaces, use cases
├── data/          # Repository implementations, data sources, models
└── presentation/  # Pages, widgets, cubits
```

### Layer rules

1. **domain** is pure Dart. It never imports Flutter, Firebase, `data` or
   `presentation`. It contains entities, `abstract` repository interfaces and
   use cases (`UseCase<T, Params>`).
2. **data** implements the domain repositories (with data sources and models)
   and depends only on `domain` (and `core`).
3. **presentation** contains pages, widgets and cubits. It depends on `domain`
   only and **never** imports `data`.
4. Dependencies are injected with **get_it**, and every registration lives in
   `lib/core/di/injection.dart`. `core/di` and `core/router` are the
   composition root: the only places allowed to wire features together.
5. Errors are values: repositories and use cases return `Result<T>`
   (`Success` / `Failure`, a sealed class in `core/result`). Repositories catch
   every exception and return a `Failure` holding an `AppFailure`
   (`core/error`). **No exception ever reaches the UI.**
6. Navigation always uses the constants of `AppRoutes`. Screens that are not
   implemented yet point to `PlaceholderPage`.

Rules 1 to 3 are checked automatically by
`test/architecture/layer_dependencies_test.dart`: `flutter test` fails if a
layer imports a forbidden one.

The `home` feature is the **reference implementation**: copy its structure
for new features.

### Data flow

```
HomePage ──BlocProvider──▶ HomeCubit ──▶ GetWelcomeItems ──▶ HomeRepository (interface)
                                                                    ▲
                                              HomeRepositoryImpl ───┘ ──▶ HomeDataSource
```

### Roles and navigation

`UserRole` (`student`, `professor`, `admin`) is defined in `core/session`. The
router `redirect` sends each role to its own home (`/student`, `/professor`,
`/admin`) and signed-out users to `/login`.

Until authentication exists, the role comes from a temporary
`CurrentSession` (default role: `student`, registered in get_it). It will be
replaced by the authentication feature (SCRUM-25 / SCRUM-28).

## Project structure

```
lib/
├── app.dart                      # MaterialApp.router
├── main.dart                     # configureDependencies() + runApp
├── core/
│   ├── di/injection.dart         # get_it registrations (all features)
│   ├── error/failure.dart        # AppFailure hierarchy
│   ├── result/result.dart        # Result<T>: Success / Failure
│   ├── router/
│   │   ├── app_router.dart       # GoRouter + role-based redirect
│   │   └── app_routes.dart       # Route path constants
│   ├── session/
│   │   ├── current_session.dart  # TEMPORARY session (until auth)
│   │   └── user_role.dart        # student / professor / admin
│   ├── theme/app_theme.dart
│   ├── usecase/usecase.dart      # UseCase<T, Params>, NoParams
│   └── widgets/placeholder_page.dart
└── features/
    └── home/                     # Reference feature
        ├── data/
        │   ├── datasources/home_data_source.dart
        │   ├── models/welcome_item_model.dart
        │   └── repositories/home_repository_impl.dart
        ├── domain/
        │   ├── entities/welcome_item.dart
        │   ├── repositories/home_repository.dart
        │   └── usecases/get_welcome_items.dart
        └── presentation/
            ├── cubit/home_cubit.dart, home_state.dart
            ├── pages/home_page.dart
            └── widgets/welcome_item_card.dart

test/                             # Mirrors lib/
├── app_test.dart                 # Smoke tests with the real DI graph
├── architecture/layer_dependencies_test.dart
├── core/
└── features/home/{domain,data,presentation}/
```

## Getting started

### Prerequisites

- Flutter **3.35.3** (stable channel), Dart **3.9.2**. Check with
  `flutter --version`.
- Android Studio or the Android SDK for Android builds.
- macOS with Xcode for iOS builds.

### Commands

```bash
flutter pub get     # Install dependencies
flutter analyze     # Static analysis: must report 0 issues
flutter test        # Run all tests: must pass
flutter run         # Run on a connected device or emulator
```

Before opening a pull request, run `flutter analyze` and `flutter test`;
both must be clean. Use `dart format .` to format the code.

### Firebase setup

The app calls `Firebase.initializeApp()` on startup and reads its
configuration from a platform file that is **not committed** (it is listed in
`.gitignore`). Every developer must add it locally once, otherwise the Android
build fails with `File google-services.json is missing`.

1. Ask the team lead to add your Google account to the Firebase project
   (Firebase console > Project settings > Users and permissions).
2. Get the config file, using **one** of these options:
   - **Console**: Project settings > General > Your apps > Android app
     `hr.foi.uniconnect` > download `google-services.json` and save it as
     `android/app/google-services.json`.
   - **FlutterFire CLI**:
     ```bash
     npm install -g firebase-tools
     dart pub global activate flutterfire_cli
     firebase login
     flutterfire configure --platforms=android
     ```
     Pick the UniConnect project. The CLI writes
     `android/app/google-services.json` and `lib/firebase_options.dart` (both
     ignored by git). Do not commit any changes it makes to the Gradle files.
3. Run `flutter run`. The app starts without a Firebase error.

Never commit `google-services.json`, `GoogleService-Info.plist`,
`firebase_options.dart`, service account keys (`*-firebase-adminsdk-*.json`)
or `.env` files. If one was committed by mistake, tell the team so the keys
can be rotated: deleting the file in a later commit does not remove it from
the git history.

## Conventions

- **Branches**: one branch per Jira ticket, created from an up-to-date `main`:
  `feature/SCRUM-xx-short-description` (e.g.
  `feature/SCRUM-14-architecture-navigation`).
- **Commits**: small and focused, in English, starting with the Jira key:
  `SCRUM-xx Short description` (e.g. `SCRUM-14 Add core layer`).
- **Pull requests**: always target `main`, need **at least one review** before
  merging, and must pass `flutter analyze` and `flutter test`. Nobody pushes
  directly to `main`.
- **Code style**: lints are defined in `analysis_options.yaml`
  (`flutter_lints` plus single quotes, const constructors, final locals,
  explicit return types, ordered directives, no `print`).
- **Imports**: use `package:uniconnect/...` imports.
- **Tests**: the `test/` tree mirrors `lib/`. Every use case, repository and
  cubit has unit tests; every page has a widget test using a mocked cubit.

## How to add a new feature

Example: an `attendance` feature with a "My attendance" screen.

1. **Create the folders** `lib/features/attendance/{domain,data,presentation}`
   (and the same tree under `test/features/attendance/`).
2. **Domain**: add the entities (`entities/attendance_record.dart`, pure
   Dart, extending `Equatable`), the repository interface
   (`repositories/attendance_repository.dart`, `abstract interface class`
   returning `Future<Result<...>>`), and one use case per action
   (`usecases/get_my_attendance.dart`, extending `UseCase<T, Params>`).
3. **Data**: add the models (`fromMap` / `toEntity`), the data source(s)
   (in-memory for now, Firestore later) and `AttendanceRepositoryImpl`, which
   catches every exception and returns a `Failure`.
4. **Presentation**: add a cubit with a sealed state class (loading / loaded /
   error) that calls the use cases, then the page (`BlocProvider` with
   `create: (_) => getIt<MyAttendanceCubit>()`) and a view that reads the
   cubit from the context.
5. **Dependency injection**: add a `_registerAttendanceFeature()` function in
   `core/di/injection.dart` (lazy singletons for data sources, repositories
   and use cases, a factory for the cubit) and call it from
   `configureDependencies()`.
6. **Navigation**: if needed, add the path to `AppRoutes`, then replace the
   `PlaceholderPage` builder of the route in `core/router/app_router.dart`
   with the new page. Navigate with `context.push(AppRoutes.myAttendance)`.
7. **Tests**: use case and repository tests (mocked dependencies with
   `mocktail`), cubit tests (`blocTest`), a widget test of the page with a
   `MockCubit`, and router tests for new routes.
8. **Check and open the PR**: `flutter analyze` (0 issues) and `flutter test`
   (all green, including the architecture test), then open a pull request to
   `main` from `feature/SCRUM-xx-...`.
