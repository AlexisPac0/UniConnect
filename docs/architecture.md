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
