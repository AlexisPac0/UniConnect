# UniConnect

UniConnect is a Flutter mobile app for university students, professors and
administrators, targeting Android and iOS. Its planned modules are **Timetable**
(courses, personal schedules and change notifications) and **Attendance**
(QR-code and geolocation check-in, with attendance statistics).

## Current status

The project currently provides the application foundation: layered architecture,
role-based navigation and a reference home feature backed by in-memory data.
Other screens are placeholders. Firebase Authentication, Cloud Firestore and
Cloud Messaging are planned but are **not integrated yet**.

No Firebase account, credentials or environment file is required to run the
current app. A temporary session starts as a student; this is not real
authentication.

## Getting started

### Prerequisites

- Git and the [Flutter SDK](https://docs.flutter.dev/install), available on your
  command line. The project's documented reference is **Flutter 3.35.3 stable**
  with **Dart 3.9.2** (Dart is bundled with Flutter).
- For Android: Android Studio with the Android SDK and an emulator, or an
  Android device with USB debugging enabled.
- For iOS: macOS with Xcode and an iOS simulator or configured physical device.
  Follow the [Flutter iOS setup guide](https://docs.flutter.dev/platform-integration/ios/setup).

Check your installation and resolve issues for your target platform:

```bash
flutter --version
flutter doctor
```

### Install and run

```bash
git clone https://github.com/AlexisPac0/UniConnect.git
cd UniConnect
flutter pub get
```

Start an Android emulator from Android Studio's Device Manager, or an iOS
simulator from Xcode on macOS. Alternatively, connect a configured device.

```bash
flutter devices
flutter run
```

If several devices are available, select one with
`flutter run -d <device-id>`, using an ID from `flutter devices`.
The app opens the student home screen with sample data.

### Checks

Run these from the repository root before opening a pull request:

```bash
flutter analyze
flutter test
```

If no device is listed, start an emulator or check the device connection and
rerun `flutter doctor`. For SDK or dependency errors, check `flutter --version`
against the project constraints before retrying `flutter pub get`.

## Tech stack

| Concern | Choice |
| --- | --- |
| UI | Flutter / Material 3 |
| State management | flutter_bloc / Cubit |
| Navigation | go_router |
| Dependency injection | get_it |
| Value equality | equatable |
| Tests | flutter_test, mocktail, bloc_test |
| Backend (planned) | Firebase |

## Documentation and contributing

- [Architecture](docs/architecture.md): layers, data flow, roles and project structure.
- [Contributing](CONTRIBUTING.md): Git workflow, checks and adding a feature.
- [Use cases](docs/uml/use-case-descriptions.md).
- [Use-case diagram](docs/uml/usecase.png) and [PlantUML source](docs/uml/usecase.puml).
- [Jira project](https://uniconnecterasmus.atlassian.net).

Create a branch named `feature/SCRUM-xx-short-description` from an up-to-date
`main`. Use English commits prefixed with the Jira key, and open a pull request
to `main` for at least one approval. See the contributing guide for the full
workflow and branch-protection setup.
