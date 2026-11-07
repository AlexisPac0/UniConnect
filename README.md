# UniConnect
UniConnect is a mobile app for university students that brings together information and tools currently scattered across different platforms. It is designed for both local Croatian students and Erasmus students, and aims to make everyday university life easier to organise and more social.

## Development

This repository contains the initial Flutter app shell.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Application code follows a feature-based structure:

- `lib/core`: shared application concerns such as theming.
- `lib/features/<feature>/presentation`: screens and widgets.
- `lib/features/<feature>/domain`: feature entities and business rules.
- `lib/features/<feature>/data`: repositories and data sources.
