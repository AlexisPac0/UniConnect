# Contributing

[README](README.md) · [Architecture](docs/architecture.md)

Follow the [getting-started instructions](README.md#getting-started) before
working on the project.

## Conventions

- **Branches**: one branch per Jira ticket, created from an up-to-date `main`:
  `<prefix>/SCRUM-<number>-<short-description>`. Allowed prefixes are
  `feature`, `feat`, `fix`, `docs`, `refactor`, `test`, and `chore`.
  Use a lowercase, hyphen-separated English description (e.g.
  `feature/SCRUM-14-architecture-navigation` or
  `chore/SCRUM-16-set-up-ci-pipeline`).
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

Ticket branches use `<prefix>/SCRUM-<number>-<short-description>` with any
of the allowed prefixes listed above. Choose a prefix that describes the
work; `feature` and `feat` both denote new functionality. For example,
`feature/SCRUM-14-architecture-navigation` and
`chore/SCRUM-16-set-up-ci-pipeline` are valid branch names. The initial setup
also has a legacy `chore/initialize-flutter-project` branch; new branches
must include the Jira key.

Start each ticket from an up-to-date main branch with a clean working tree:

```bash
git switch main
git pull --ff-only origin main
git switch -c feature/SCRUM-17-readme-git-workflow
```

Replace the example branch name with your chosen prefix, ticket key, and a
short, lowercase, hyphen-separated English description. Keep changes focused
on the ticket. Format modified Dart code
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

The **Repository conventions** workflow runs on pull requests targeting
`main` and pushes to `main`, not on pushes to other branches. After its first
run, enable **Require status checks to pass before merging** and select
**Branch naming**, **Commit conventions**, **Flutter analyze**, and
**Flutter test** (GitHub Actions as the source). Run both workflows first
so all four checks are available to select.
These settings are required to block merges when a policy check fails;
adding the workflow alone does not enable branch protection.

The branch check enforces the format and prefixes above, with a positive
ticket number and a lowercase, hyphen-separated description. `main` itself
is exempt. The commit check validates every non-merge commit introduced by
the PR, excluding commits already on the target branch. On pushes to `main`,
it checks the newly introduced commits between the before and after SHAs.
Actual merge commits are excluded based on parent count, not their messages.

Commit subjects must use `<type>: <description> (SCRUM-<positive-number>)`
with a type from the commit table above and a nonempty description. Optional
commit bodies are allowed. Ticket numbers do not need to match the branch
ticket. English wording and imperative style remain review responsibilities.
An invalid earlier commit still fails the check even if the latest commit
is valid; correct the offending messages before merging. Feature branches
can receive any commits, but their PRs must pass these checks. A check on a
push to `main` detects violations after the push; it cannot reject the push
retroactively. When squash merging, ensure the final squash commit subject
also follows the convention.

Run the policy validator tests locally with Node.js 20 or newer:

```bash
node --test .github/scripts/check-conventions.test.mjs
```

The **Flutter CI** workflow runs on the same PR and push events. It installs
the latest stable Flutter SDK and dependencies, then runs `flutter analyze`
and `flutter test` as independent checks on Linux. An analysis failure does
not cancel the tests. `flutter test` runs the full `test/` suite, including
unit, widget, and architecture tests; no emulator is required.
The SDK version is printed in each job's log. CI follows the stable channel
rather than pinning an SDK release. Continue running both checks locally
before opening a PR.

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
   `main` from `<prefix>/SCRUM-<number>-<short-description>` using an allowed
   prefix.
