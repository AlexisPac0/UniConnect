# Architecture

[README](../README.md) · [Contributing](../CONTRIBUTING.md)

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
router `redirect` sends the app to `/splash` while the session is loading,
signed-out users to `/login`, and each role to its own home (`/student`,
`/professor`, `/admin`).

Access rules live in `core/session`: `RoleAccessPolicy` lists the
`AppFeature`s of each role, and `AppRoutes.featureFor` maps every screen to
its feature. A signed-in user who opens a screen of another role is sent back
to their own home.

| Feature | Routes | Student | Professor | Admin |
| --- | --- | :-: | :-: | :-: |
| `timetable` | `/timetable/**` | ✓ | ✓ | ✓ |
| `attendanceCheckIn` | `/attendance/scan` | ✓ | | |
| `myAttendance` | `/attendance/me` | ✓ | | |
| `attendanceSession` | `/attendance/session` | | ✓ | |
| `attendanceDashboard` | `/attendance/dashboard` | | ✓ | ✓ |
| `courseManagement` | `/courses/**` | | | ✓ |
| `settings` | `/settings` | ✓ | ✓ | ✓ |

### Session flow

```
Firebase Auth ──▶ WatchAuthState ──▶ SessionController ──▶ GetUserProfile (users/{id})
                                            │
                                            ▼
                                       AppSession ──refreshListenable──▶ GoRouter redirect
```

`AppSession` (`core/session`) holds the session state: `loading`, `signedOut`
(with an optional error message) or `signedIn` (user id, role, display name).
`SessionController` (`profile/presentation/session`) is started by `main`. It
listens to Firebase Auth: nobody signed in gives `signedOut`; a signed-in user
gives `loading`, then `signedIn` with the role of their profile, or
`signedOut` with the failure message when the profile is missing or its role
is invalid. If the user changes while a profile loads, the outdated result is
ignored. `core` never imports a feature: it only knows `AppSession`.

The three ways a session starts or ends:

- **Restored at startup.** Firebase Auth keeps the user signed in on the
  device and `authStateChanges()` emits them as its first event. The app
  opens on `/splash` (`loading`), loads the profile, then goes to the home of
  the role. Nothing else is needed: it is the same path as a new sign-in.
- **Log out.** The `SignOutButton` (in the home `AppBar`) asks for a
  confirmation, then calls `SignOutCubit` → `SignOut` →
  `FirebaseAuth.signOut()`. It never navigates: Firebase Auth emits `null`,
  `SessionController` sets `signedOut`, and the router redirects to `/login`.
  If signing out fails, a `SnackBar` shows the message and the user stays
  signed in.
- **Forced sign-out.** When the profile cannot be loaded (missing document,
  invalid role...), `SessionController` sets `signedOut` with the failure
  message, then calls `SignOut` so that the user does not stay signed in to
  Firebase without being able to use the app. The `null` that Firebase emits
  next keeps the message, so the login screen can display it. If `SignOut`
  fails, the session stays `signedOut` and it is not retried.

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
│   │   ├── app_feature.dart      # Features guarded by role
│   │   ├── app_session.dart      # loading / signedOut / signedIn
│   │   ├── role_access_policy.dart # Features allowed per role
│   │   └── user_role.dart        # student / professor / admin
│   ├── theme/app_theme.dart
│   ├── usecase/usecase.dart      # UseCase<T, Params>, NoParams
│   └── widgets/
│       ├── placeholder_page.dart
│       └── splash_page.dart
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

## Architectural specifications and diagrams

- [Component architecture specification](architecture/component-architecture.md) (SCRUM-22)
- [Domain model class diagram](architecture/domain-model-class-diagram.md) (SCRUM-20)
- [Firestore data model](firestore-data-model.md) (SCRUM-23)

