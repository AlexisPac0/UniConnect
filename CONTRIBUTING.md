# Contributing

Set up the project first: see the [README](README.md).

## Branches and commits

One branch per Jira ticket, from an up-to-date `main`:
`<prefix>/SCRUM-<number>-<short-description>`, lowercase and hyphens only
(e.g. `feature/SCRUM-25-login-screen`).

Commit subjects, in English and imperative: `<type>: <description> (SCRUM-<number>)`
(e.g. `fix: update Kotlin to 2.3.21 (SCRUM-13)`).

| Prefix / type | Use |
| --- | --- |
| `feature`, `feat` | New functionality |
| `fix` | Bug fix |
| `docs` | Documentation |
| `refactor` | Restructuring without behaviour change |
| `test` | Tests |
| `chore` | Tooling, CI, maintenance |

CI rejects a pull request whose branch name or any commit subject does not
follow these formats.

```bash
git switch main && git pull --ff-only
git switch -c feature/SCRUM-<number>-<short-description>
# ... work, dart format ., flutter analyze, flutter test
git push -u origin feature/SCRUM-<number>-<short-description>
```

## Pull requests

- Target `main`, never push to `main` directly.
- Link the Jira ticket, summarise the change and how it was tested.
- At least **one approval** from another member before merging.
- CI must pass: branch naming, commit conventions, `flutter analyze`,
  `flutter test`, and the Firestore rules tests. A change to
  `firestore.rules` needs matching tests in
  `firestore-tests/firestore.rules.test.mjs`.

## Code rules

- Follow the layers of [the architecture](docs/architecture.md); the
  architecture test fails if a layer imports a forbidden one.
- Lints are in `analysis_options.yaml`; use `package:uniconnect/...` imports.
- UI: never hardcode colours, text styles or spacing. Use the theme
  (`context.colors`, `context.textStyles`, `context.semanticColors`),
  `AppSpacing` / `AppRadius` / `AppSizes` and the widgets of `core/widgets`.
- Tests mirror `lib/` in `test/`: every use case, repository and cubit has
  unit tests, every page a widget test with a mocked cubit.

## Adding a feature

Copy the structure of `lib/features/home` (the reference feature):

1. `domain/`: entities (`Equatable`), repository interface returning
   `Future<Result<...>>`, one use case per action (`UseCase<T, Params>`).
2. `data/`: models, data sources, repository implementation that catches
   every exception and returns a `Failure`.
3. `presentation/`: cubit with a sealed state, page providing the cubit with
   `getIt`, view reading it from the context.
4. Register everything in `core/di/injection.dart` (lazy singletons, factory
   for the cubit).
5. Route: add the path to `AppRoutes` and replace the `PlaceholderPage` in
   `core/router/app_router.dart`.
6. Tests for each layer, plus router tests for new routes.

## Main branch protection (admin, not enabled yet)

In GitHub, Settings > Branches, add a rule for `main`: require a pull
request with 1 approval, require the CI checks above, do not allow
bypassing, no force pushes or deletions.
