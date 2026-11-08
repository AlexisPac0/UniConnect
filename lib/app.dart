import 'package:flutter/material.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/theme/app_theme.dart';
import 'package:uniconnect/features/home/presentation/pages/home_page.dart';

class UniConnectApp extends StatelessWidget {
  const UniConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniConnect',
      theme: AppTheme.light,
      home: const HomePage(role: UserRole.student),
    );
  }
}
