import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/app_loader.dart';

/// Screen shown while the app does not know yet who is signed in.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: AppSizes.iconXl,
              color: context.colors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('UniConnect', style: context.textStyles.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            const AppLoader(),
          ],
        ),
      ),
    );
  }
}
