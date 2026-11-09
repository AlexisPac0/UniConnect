import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/app.dart';
import 'package:uniconnect/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No explicit options: on Android the configuration comes from
  // android/app/google-services.json (on iOS, GoogleService-Info.plist).
  // Those files are not committed, see "Firebase setup" in README.md.
  await Firebase.initializeApp();
  configureDependencies();
  runApp(UniConnectApp(router: getIt<GoRouter>()));
}
