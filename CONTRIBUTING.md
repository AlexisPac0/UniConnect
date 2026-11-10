# Contributing

[README](README.md) · [Architecture](docs/architecture.md)

Follow the [getting-started instructions](README.md#getting-started) before
working on the project.

## Conventions

- **Branches**: one branch per Jira ticket, created from an up-to-date `main`:
  `feature/SCRUM-xx-short-description` (e.g.
  `feature/SCRUM-14-architecture-navigation`).
- **Commits**: small and focused, in English, using Conventional Commits with
  the Jira key at the end: `<type>: <description> (SCRUM-xx)` (e.g.
  `docs: improve README and document Git workflow (SCRUM-17)`).
- **Pull requests**: always target `main`, need **at least one review** before
  merging, and must pass `flutter analyze` and `flutter test`. Nobody pushes
  directly to `main`.
- **Code style**: lints are defined in `analysis_options.yaml`
  (`flutter_lints` plus single quotes, const constructors, final locals,
  explicit return types, ordered directives, no `print`).
- **Imports**: use `package:uniconnect/...` imports.
- **Tests**: the `test/` tree mirrors `lib/`. Every use case, repository and
  cubit has unit tests; every page has a widget test using a mocked cubit.

## Commit messages

Use a short, imperative description (for example, "add" rather than "added")
and include the Jira ticket key in parentheses at the end.

| Type | Purpose |
| --- | --- |
| `feat` | New functionality |
| `fix` | Bug fixes |
| `docs` | Documentation changes |
| `refactor` | Code restructuring without changing behavior |
| `test` | Adding or updating tests |
| `chore` | Maintenance or tooling changes |

For this documentation change:

```text
docs: improve README and document Git workflow (SCRUM-17)
```

## Git workflow

The existing ticket branches use `feature/SCRUM-xx-short-description`
(for example, `feature/SCRUM-14-architecture-navigation` and
`feature/SCRUM-19-use-case-diagram`). The initial setup also has a legacy
`chore/initialize-flutter-project` branch.

Start each ticket from an up-to-date main branch with a clean working tree:

```bash
git switch main
git pull --ff-only origin main
git switch -c feature/SCRUM-17-readme-git-workflow
```

Replace the example branch name with your ticket key and a short English
description. Keep changes focused on the ticket. Format modified Dart code
with `dart format .`, then run:

```bash
flutter analyze
flutter test
```

Commit only the intended files using an English message such as
`docs: improve README and document Git workflow (SCRUM-17)`, then push your branch:

```bash
git push -u origin feature/SCRUM-17-readme-git-workflow
```

Open a pull request targeting `main`. Include the Jira ticket link, a summary
of the change and validation results, including any checks you could not run.
Obtain at least one approval from another contributor and address review
feedback before merging. Do not push changes directly to `main`.

## Main branch protection (administrator setup)

These are the required repository settings, not proof that protection is
already enabled. An administrator must configure and verify them in GitHub.
Until then, follow the review workflow above manually.

In **Settings → Branches → Add classic branch protection rule**, set the
branch name pattern to `main` and configure:

- **Require a pull request before merging**.
- **Require approvals**, with **1** required approval.
- **Do not allow bypassing the above settings**, so the rule also applies
  to administrators.
- Leave **Allow force pushes** and **Allow deletions** disabled.

There is currently no GitHub Actions workflow in the repository. Run the
analysis and tests locally and record the results in the PR; do not configure
required status checks that do not exist.

After saving, verify that the rule targets `main` and that GitHub shows the
approval requirement on a pull request. SCRUM-17 is not complete until this
protection is enabled as well as the documentation delivered.

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
