import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/core/theme/app_theme.dart';

class UniConnectApp extends StatelessWidget {
  const UniConnectApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UniConnect',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
