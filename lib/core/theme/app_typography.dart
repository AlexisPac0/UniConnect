import 'package:flutter/material.dart';

/// Type scale of the app, following the Material 3 roles
/// (display / headline / title / body / label).
///
/// Styles carry no colour: `ThemeData` adds the right one for the
/// brightness. Read them with `context.textStyles.titleLarge`.
abstract final class AppTypography {
  /// PLACEHOLDER: `null` uses the platform font (Roboto on Android, SF on
  /// iOS). To use a brand font, declare it under `flutter: fonts:` in
  /// pubspec.yaml and put its family name here.
  static const String? fontFamily = null;

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      height: 64 / 57,
      letterSpacing: -0.25,
      fontWeight: FontWeight.w400,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      height: 52 / 45,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      height: 44 / 36,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      height: 40 / 32,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 36 / 28,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 32 / 24,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      height: 28 / 22,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: 0.15,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0.25,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.4,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 16 / 11,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w500,
    ),
  );
}
