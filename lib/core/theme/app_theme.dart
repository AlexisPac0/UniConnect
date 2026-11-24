import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/app_colors.dart';
import 'package:uniconnect/core/theme/app_spacing.dart';
import 'package:uniconnect/core/theme/app_typography.dart';

/// Light and dark [ThemeData] of the app, built from [AppColors],
/// [AppTypography] and the spacing tokens.
///
/// Component themes are set here so plain Material widgets (`FilledButton`,
/// `Card`, `TextField`, `AppBar`…) already match the design system.
abstract final class AppTheme {
  static final ThemeData light = _build(
    AppColors.lightScheme,
    AppColors.lightSemantic,
  );

  static final ThemeData dark = _build(
    AppColors.darkScheme,
    AppColors.darkSemantic,
  );

  static ThemeData _build(ColorScheme scheme, AppSemanticColors semantic) {
    const buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.mdAll);
    const buttonMinimumSize = Size(64, AppSizes.buttonHeightMd);
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.lg);
    final buttonTextStyle = AppTypography.textTheme.labelLarge;

    OutlineInputBorder inputBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [semantic],
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.medium,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonMinimumSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonTextStyle,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonMinimumSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonMinimumSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonTextStyle,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonMinimumSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: buttonShape,
          textStyle: buttonTextStyle,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: AppElevation.low,
        margin: const EdgeInsets.all(AppSpacing.xs),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: inputBorder(scheme.outline),
        enabledBorder: inputBorder(scheme.outline),
        focusedBorder: inputBorder(scheme.primary, width: 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, width: 2),
        disabledBorder: inputBorder(scheme.onSurface.withValues(alpha: 0.12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.md,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      ),
    );
  }
}
