# Architecture

## Tech stack

| Concern | Choice |
| --- | --- |
| UI | Flutter, Material 3 |
| State management | `flutter_bloc` (Cubit) |
| Navigation | `go_router` |
| Dependency injection | `get_it` |
| Backend | Firebase Auth, Cloud Firestore (Cloud Functions and Messaging planned) |
| Tests | `flutter_test`, `mocktail`, `bloc_test` |

## Structure

```
lib/
├── main.dart, app.dart
├── core/          # Shared code, never imports a feature
│   ├── di/        # get_it registrations (composition root)
│   ├── router/    # GoRouter, AppRoutes, role-based redirect
│   ├── session/   # AppSession, UserRole, RoleAccessPolicy
│   ├── result/    # Result<T>: Success / Failure
│   ├── error/     # AppFailure
│   ├── usecase/   # UseCase<T, Params>
│   ├── theme/     # Design system (colours, typography, spacing)
│   ├── widgets/   # Shared widgets (AppButton, AppCard, ...)
│   └── dev/       # Debug-only UI gallery
└── features/<feature>/
    ├── domain/        # Pure Dart: entities, repository interfaces, use cases
    ├── data/          # Repository implementations, data sources, models
    └── presentation/  # Pages, widgets, cubits
test/                  # Mirrors lib/
```

Features: `auth` (sign in, sign out), `profile` (user profile, session),
`home` (reference feature, copy its structure).

## Layer rules

1. **domain** is pure Dart: no Flutter, Firebase, `data` or `presentation`.
2. **data** implements the domain repositories and depends only on `domain`
   and `core`.
3. **presentation** depends on `domain` only, never on `data`.
4. Only `core/di` and `core/router` wire features together.
5. Errors are values: repositories catch every exception and return a
   `Failure` holding an `AppFailure`. No exception reaches the UI.
6. Navigation uses the `AppRoutes` constants. Screens not built yet show
   `PlaceholderPage`.

Rules 1 to 3 are checked by `test/architecture/layer_dependencies_test.dart`.

## Roles and navigation

The router sends the app to `/splash` while the session loads, signed-out
users to `/login`, and each role to its home (`/student`, `/professor`,
`/admin`). A user who opens a screen of another role goes back to their home.

| Feature | Routes | Student | Professor | Admin |
| --- | --- | :-: | :-: | :-: |
| `timetable` | `/timetable/**` | ✓ | ✓ | ✓ |
| `attendanceCheckIn` | `/attendance/scan` | ✓ | | |
| `myAttendance` | `/attendance/me` | ✓ | | |
| `attendanceSession` | `/attendance/session` | | ✓ | |
| `attendanceDashboard` | `/attendance/dashboard` | | ✓ | ✓ |
| `courseManagement` | `/courses/**` | | | ✓ |
| `settings` | `/settings` | ✓ | ✓ | ✓ |

Defined in `core/session/role_access_policy.dart` and `AppRoutes.featureFor`.

## Session

```
Firebase Auth ──▶ SessionController ──▶ GetUserProfile (users/{uid})
                         │
                         ▼
                    AppSession ──▶ GoRouter redirect
```

`SessionController` listens to Firebase Auth and sets `AppSession` to
`loading`, `signedIn` (id, role, name) or `signedOut` (with an optional
error message).

- **Restored at startup:** Firebase Auth keeps the user signed in; the app
  loads the profile and opens the home of the role.
- **Log out:** the button of the home asks for confirmation and signs out of
  Firebase; the router then redirects to `/login`.
- **Forced sign-out:** if the profile is missing or invalid, the user is
  signed out and the login screen shows why.

## Design system

`core/theme` is the single source for colours (`context.colors`,
`context.semanticColors`), text styles (`context.textStyles`) and spacing
(`AppSpacing`, `AppRadius`, `AppSizes`). The app follows the system
light/dark setting. In debug builds, the palette button of the home opens a
gallery of every token and widget.
