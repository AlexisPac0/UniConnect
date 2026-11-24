import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/theme/theme.dart';

import '../../helpers/pump_themed.dart';

void main() {
  group('AppTheme', () {
    test('light and dark themes use the matching colour schemes', () {
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.light.colorScheme, AppColors.lightScheme);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.dark.colorScheme, AppColors.darkScheme);
      expect(AppTheme.light.useMaterial3, isTrue);
    });

    test('both themes register their semantic colours', () {
      expect(
        AppTheme.light.extension<AppSemanticColors>(),
        AppColors.lightSemantic,
      );
      expect(
        AppTheme.dark.extension<AppSemanticColors>(),
        AppColors.darkSemantic,
      );
    });

    test('semantic error colours mirror the colour scheme', () {
      final light = AppColors.lightSemantic.error;
      expect(light.color, AppColors.lightScheme.error);
      expect(light.onColor, AppColors.lightScheme.onError);
      expect(light.container, AppColors.lightScheme.errorContainer);
      expect(light.onContainer, AppColors.lightScheme.onErrorContainer);
    });

    test('the text theme follows the type scale', () {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        final textTheme = theme.textTheme;
        expect(
          textTheme.headlineMedium?.fontSize,
          AppTypography.textTheme.headlineMedium?.fontSize,
        );
        expect(
          textTheme.bodyMedium?.fontSize,
          AppTypography.textTheme.bodyMedium?.fontSize,
        );
        expect(textTheme.bodyMedium?.color, isNotNull);
      }
    });

    test('component themes use the design tokens', () {
      final theme = AppTheme.light;
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      expect(
        (theme.cardTheme.shape! as RoundedRectangleBorder).borderRadius,
        AppRadius.mdAll,
      );
      expect(theme.cardTheme.elevation, AppElevation.low);
      expect(
        theme.filledButtonTheme.style?.minimumSize?.resolve({})?.height,
        AppSizes.buttonHeightMd,
      );
    });

    test('semantic colours interpolate between themes', () {
      final halfway = AppColors.lightSemantic.lerp(AppColors.darkSemantic, 0.5);
      expect(
        halfway.success.color,
        isNot(AppColors.lightSemantic.success.color),
      );
      expect(
        AppColors.lightSemantic.lerp(AppColors.darkSemantic, 0),
        AppColors.lightSemantic,
      );
    });
  });

  group('AppThemeContext', () {
    Future<BuildContext> contextIn(
      WidgetTester tester,
      ThemeMode themeMode,
    ) async {
      late BuildContext captured;
      await pumpThemed(
        tester,
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
        themeMode: themeMode,
      );
      return captured;
    }

    testWidgets('exposes the light theme', (tester) async {
      final context = await contextIn(tester, ThemeMode.light);

      expect(context.colors, AppColors.lightScheme);
      expect(context.semanticColors, AppColors.lightSemantic);
      expect(context.textStyles.titleLarge?.fontSize, 22);
    });

    testWidgets('exposes the dark theme', (tester) async {
      final context = await contextIn(tester, ThemeMode.dark);

      expect(context.colors, AppColors.darkScheme);
      expect(context.semanticColors, AppColors.darkSemantic);
    });

    testWidgets('falls back to default semantic colours without the theme', (
      tester,
    ) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        captured.semanticColors.success,
        AppSemanticColors.dark(captured.colors).success,
      );
    });
  });
}
