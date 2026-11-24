import 'package:flutter/widgets.dart';

/// Spacing scale, on a 4 dp grid. Use it for every padding, margin and gap:
/// `const EdgeInsets.all(AppSpacing.md)`, `const SizedBox(height: AppSpacing.sm)`.
///
/// These are compile-time constants rather than a theme extension so they
/// can be used in `const` widgets; they do not change with the theme.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Corner radius tokens.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 28;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}

/// Elevation tokens (Material 3 levels 0, 1, 2 and 3).
abstract final class AppElevation {
  static const double none = 0;
  static const double low = 1;
  static const double medium = 3;
  static const double high = 6;
}

/// Fixed component sizes: icons, tap targets, buttons and loaders.
abstract final class AppSizes {
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 48;
  static const double iconXl = 72;

  /// Minimum size of anything tappable (Material / WCAG guideline).
  static const double minTapTarget = 48;

  static const double buttonHeightSm = 40;
  static const double buttonHeightMd = 48;
  static const double buttonHeightLg = 56;

  static const double loaderSm = 20;
  static const double loaderMd = 36;
  static const double loaderLg = 48;
}
