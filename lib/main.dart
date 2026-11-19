import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/app.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/features/profile/presentation/session/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  getIt<SessionController>().start();
  runApp(UniConnectApp(router: getIt<GoRouter>()));
}
