import 'package:flutter/material.dart';

/// Colour palette of the app: the Material 3 [ColorScheme]s and the
/// [AppSemanticColors] for each brightness.
///
/// PLACEHOLDER: the seed and the semantic colours are defaults chosen before
/// an official brand palette exists. Replace them here; nothing else in the
/// app hardcodes a colour.
abstract final class AppColors {
  /// Seed of the generated colour schemes (university blue).
  static const Color seed = Color(0xFF2457A6);

  static final ColorScheme lightScheme = ColorScheme.fromSeed(seedColor: seed);

  static final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );

  /// Semantic colours of the light theme.
  static final AppSemanticColors lightSemantic = AppSemanticColors.light(
    lightScheme,
  );

  /// Semantic colours of the dark theme.
  static final AppSemanticColors darkSemantic = AppSemanticColors.dark(
    darkScheme,
  );
}

/// A semantic colour role with its Material 3 style companions: [color] for
/// fills, [onColor] for content on [color], and the softer [container] /
/// [onContainer] pair for backgrounds such as badges and banners.
@immutable
class SemanticColor {
  const SemanticColor({
    required this.color,
    required this.onColor,
    required this.container,
    required this.onContainer,
  });

  final Color color;
  final Color onColor;
  final Color container;
  final Color onContainer;

  static SemanticColor lerp(SemanticColor a, SemanticColor b, double t) {
    return SemanticColor(
      color: Color.lerp(a.color, b.color, t)!,
      onColor: Color.lerp(a.onColor, b.onColor, t)!,
      container: Color.lerp(a.container, b.container, t)!,
      onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SemanticColor &&
        other.color == color &&
        other.onColor == onColor &&
        other.container == container &&
        other.onContainer == onContainer;
  }

  @override
  int get hashCode => Object.hash(color, onColor, container, onContainer);
}

/// Status colours that a [ColorScheme] does not provide: success, warning
/// and info. [error] mirrors the scheme's error roles so all four statuses
/// are read the same way (`context.semanticColors.success.container`).
///
/// Registered on the [ThemeData] by `AppTheme`; read it with
/// `context.semanticColors`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  /// PLACEHOLDER values for a light background (text contrast ≥ 4.5:1).
  factory AppSemanticColors.light(ColorScheme scheme) {
    return AppSemanticColors(
      success: const SemanticColor(
        color: Color(0xFF2E7D32),
        onColor: Color(0xFFFFFFFF),
        container: Color(0xFFC8E6C9),
        onContainer: Color(0xFF0B3D0F),
      ),
      warning: const SemanticColor(
        color: Color(0xFF8A5A00),
        onColor: Color(0xFFFFFFFF),
        container: Color(0xFFFFDDB0),
        onContainer: Color(0xFF2B1700),
      ),
      error: _errorOf(scheme),
      info: const SemanticColor(
        color: Color(0xFF0061A4),
        onColor: Color(0xFFFFFFFF),
        container: Color(0xFFD1E4FF),
        onContainer: Color(0xFF001D36),
      ),
    );
  }

  /// PLACEHOLDER values for a dark background (text contrast ≥ 4.5:1).
  factory AppSemanticColors.dark(ColorScheme scheme) {
    return AppSemanticColors(
      success: const SemanticColor(
        color: Color(0xFF81C784),
        onColor: Color(0xFF0B3D0F),
        container: Color(0xFF1E5524),
        onContainer: Color(0xFFC8E6C9),
      ),
      warning: const SemanticColor(
        color: Color(0xFFFFB955),
        onColor: Color(0xFF462A00),
        container: Color(0xFF643F00),
        onContainer: Color(0xFFFFDDB0),
      ),
      error: _errorOf(scheme),
      info: const SemanticColor(
        color: Color(0xFF9ECAFF),
        onColor: Color(0xFF003258),
        container: Color(0xFF00497D),
        onContainer: Color(0xFFD1E4FF),
      ),
    );
  }

  /// Semantic colours matching a [theme] that does not register them, such
  /// as a bare `MaterialApp` in a widget test.
  factory AppSemanticColors.fallbackFor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? AppSemanticColors.dark(theme.colorScheme)
        : AppSemanticColors.light(theme.colorScheme);
  }

  final SemanticColor success;
  final SemanticColor warning;
  final SemanticColor error;
  final SemanticColor info;

  static SemanticColor _errorOf(ColorScheme scheme) {
    return SemanticColor(
      color: scheme.error,
      onColor: scheme.onError,
      container: scheme.errorContainer,
      onContainer: scheme.onErrorContainer,
    );
  }

  @override
  AppSemanticColors copyWith({
    SemanticColor? success,
    SemanticColor? warning,
    SemanticColor? error,
    SemanticColor? info,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: SemanticColor.lerp(success, other.success, t),
      warning: SemanticColor.lerp(warning, other.warning, t),
      error: SemanticColor.lerp(error, other.error, t),
      info: SemanticColor.lerp(info, other.info, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSemanticColors &&
        other.success == success &&
        other.warning == warning &&
        other.error == error &&
        other.info == info;
  }

  @override
  int get hashCode => Object.hash(success, warning, error, info);
}
