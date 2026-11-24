import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/app.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/features/profile/presentation/session/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
    runApp(const _UnsupportedPlatformApp());
    return;
  }

  await Firebase.initializeApp();
  configureDependencies();
  getIt<SessionController>().start();
  runApp(UniConnectApp(router: getIt<GoRouter>()));
}

class _UnsupportedPlatformApp extends StatelessWidget {
  const _UnsupportedPlatformApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Firebase is not supported on Linux desktop. '
              'Run UniConnect on Android or iOS.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
