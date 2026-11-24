import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/app_colors.dart';

/// Shortcuts to the current theme:
/// `context.colors.primary`, `context.textStyles.titleLarge`,
/// `context.semanticColors.success.color`.
///
/// Spacing, radius and sizes are constants: use `AppSpacing`, `AppRadius` and
/// `AppSizes` directly so the widgets using them can stay `const`.
extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get textStyles => theme.textTheme;

  /// Falls back to default semantic colours when the theme does not register
  /// [AppSemanticColors] (for example a bare `MaterialApp` in a test).
  AppSemanticColors get semanticColors {
    return theme.extension<AppSemanticColors>() ??
        AppSemanticColors.fallbackFor(theme);
  }
}
