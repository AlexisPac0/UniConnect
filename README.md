# UniConnect

Flutter app (Android and iOS) for university students, professors and
administrators: **timetable** (courses, lectures, change notifications) and
**attendance** (QR code and location check-in, statistics). Backend:
Firebase (Auth, Firestore).

## Prerequisites

- **Flutter 3.44.0** (stable), the version used by CI.
- **Java 17** for the Android build. The Java 25 bundled with recent Android
  Studio is too new for Gradle; point Flutter to a JDK 17 with
  `flutter config --jdk-dir=<path-to-jdk-17>`.
- An Android emulator or device (iOS needs macOS and Xcode).
- Only for the seed script and the Firestore rules tests: Node.js 20+
  (plus Java 21 for the rules tests, which run the Firestore emulator).

## Run the app

```bash
git clone https://github.com/AlexisPac0/UniConnect.git
cd UniConnect
flutter pub get
```

Get `google-services.json` for the Android app `hr.foi.uniconnect` (Firebase
console, project `uniconnect-910ca`, or ask the team) and put it in
`android/app/`. It is ignored by git: never commit it. On iOS, the
equivalent is `ios/Runner/GoogleService-Info.plist`.

```bash
flutter run            # or flutter run -d <device-id>
```

## Demo accounts

There is no sign-up screen: accounts are created by an administrator. The
demo accounts (1 admin, 3 professors, 6 students, `@uniconnect.test`) are
created by `scripts/seed-users.mjs`, with a service account key
(Firebase console > Project settings > Service accounts) saved as
`service-account.json` at the root (ignored by git):

```bash
npm ci
GOOGLE_APPLICATION_CREDENTIALS=./service-account.json \
SEED_PASSWORD='<demo password>' ADMIN_SEED_PASSWORD='<admin password>' \
npm run seed:users -- --prod
```

Both passwords need 12+ characters and must differ. Share them privately,
never in the repository.

## Checks

Run before opening a pull request (CI runs the same):

```bash
flutter analyze
flutter test
npm run test:rules   # only if firestore.rules changed
```

## Documentation

- [Contributing](CONTRIBUTING.md): branches, commits, pull requests, adding a feature.
- [Architecture](docs/architecture.md): layers, roles, session, tech stack.
- [Sequence diagrams](docs/uml/sequences/README.md): login, QR attendance,
  lecture changes and push notifications (SCRUM-21).
- Specifications: [use cases](docs/specs/use-cases.md),
  [domain model](docs/specs/domain-model.md),
  [components](docs/specs/component-architecture.md),
  [Firestore data model](docs/specs/firestore-data-model.md).
  PlantUML sources are in [`docs/uml`](docs/uml).
- [Jira](https://uniconnecterasmus.atlassian.net)
