import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/theme.dart';

/// Visual weight of an [AppButton].
enum AppButtonVariant {
  /// Main action of a screen (filled, primary colour).
  primary,

  /// Secondary action (filled tonal).
  secondary,

  /// Alternative action with less emphasis (outlined).
  outlined,

  /// Lowest emphasis, e.g. in dialogs or inline (text only).
  text,

  /// Dangerous or irreversible action (filled, error colour).
  destructive,
}

/// Height and text size of an [AppButton]. Every size keeps a tap target of
/// at least 48 dp.
enum AppButtonSize { small, medium, large }

/// The app's button. Wraps the Material buttons so every action looks and
/// behaves the same.
///
/// - Disabled when [onPressed] is `null`.
/// - While [isLoading], shows a spinner in place of the [icon] and ignores
///   taps.
/// - [isFullWidth] stretches it to the width of its parent.
///
/// ```dart
/// AppButton(label: 'Save', icon: Icons.check, onPressed: save)
/// AppButton(
///   label: 'Delete',
///   variant: AppButtonVariant.destructive,
///   isLoading: deleting,
///   onPressed: delete,
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final callback = _isEnabled ? onPressed : null;
    final style = _styleFor(context);
    final child = _ButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
      iconSize: _iconSize,
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
    };

    if (!isFullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  double get _iconSize {
    return size == AppButtonSize.small ? AppSizes.iconXs : AppSizes.iconSm;
  }

  ButtonStyle _styleFor(BuildContext context) {
    final textStyles = context.textStyles;
    final (height, padding, textStyle) = switch (size) {
      AppButtonSize.small => (
        AppSizes.buttonHeightSm,
        AppSpacing.md,
        textStyles.labelMedium,
      ),
      AppButtonSize.medium => (
        AppSizes.buttonHeightMd,
        AppSpacing.lg,
        textStyles.labelLarge,
      ),
      AppButtonSize.large => (
        AppSizes.buttonHeightLg,
        AppSpacing.xl,
        textStyles.titleMedium,
      ),
    };

    final sizeStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(AppSizes.minTapTarget, height)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: variant == AppButtonVariant.text
              ? AppSpacing.md
              : padding,
        ),
      ),
      textStyle: WidgetStatePropertyAll(textStyle),
      // Small buttons are 40 dp tall but still get a 48 dp tap area.
      tapTargetSize: MaterialTapTargetSize.padded,
    );

    if (variant != AppButtonVariant.destructive) return sizeStyle;
    final colors = context.colors;
    return sizeStyle.merge(
      FilledButton.styleFrom(
        backgroundColor: colors.error,
        foregroundColor: colors.onError,
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.iconSize,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final Widget? leading = isLoading
        ? SizedBox.square(
            dimension: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              // Matches the button's (disabled) foreground colour.
              color: IconTheme.of(context).color,
            ),
          )
        : icon == null
        ? null
        : Icon(icon, size: iconSize);

    final text = Text(label, overflow: TextOverflow.ellipsis);
    if (leading == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: leading),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: text),
      ],
    );
  }
}
