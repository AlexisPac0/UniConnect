import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/widgets.dart';

/// Dev-only catalogue of every design token and shared widget variant.
///
/// Registered in debug builds only (see `app_router.dart`). The palette
/// button switches between the light and dark themes on this screen.
class UiGalleryPage extends StatefulWidget {
  const UiGalleryPage({super.key});

  @override
  State<UiGalleryPage> createState() => _UiGalleryPageState();
}

class _UiGalleryPageState extends State<UiGalleryPage> {
  Brightness? _brightness;

  @override
  Widget build(BuildContext context) {
    final brightness = _brightness ?? Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Theme(
      data: isDark ? AppTheme.dark : AppTheme.light,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('UI gallery'),
            actions: [
              IconButton(
                tooltip: isDark ? 'Show light theme' : 'Show dark theme',
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                onPressed: () => setState(
                  () =>
                      _brightness = isDark ? Brightness.light : Brightness.dark,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: const [
              _Section('Colour scheme', child: _SchemeColors()),
              _Section('Semantic colours', child: _SemanticColors()),
              _Section('Typography', child: _TypeScale()),
              _Section('Spacing', child: _SpacingScale()),
              _Section('Radius', child: _RadiusScale()),
              _Section('Buttons', child: _Buttons()),
              _Section('Cards', child: _Cards()),
              _Section('Loaders', child: _Loaders()),
              _Section(
                'Empty state',
                child: SizedBox(
                  height: 320,
                  child: Card(
                    child: EmptyState(
                      title: 'No lectures today',
                      message: 'Enjoy your free day.',
                      icon: Icons.event_available_outlined,
                      actionLabel: 'Open timetable',
                      onAction: _noop,
                    ),
                  ),
                ),
              ),
              _Section(
                'Error state',
                child: SizedBox(
                  height: 320,
                  child: Card(
                    child: ErrorState(
                      message: 'Check your connection and try again.',
                      onRetry: _noop,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _noop() {}

class _Section extends StatelessWidget {
  const _Section(this.title, {required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textStyles.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, this.onColor);

  final String name;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Text(
        name,
        style: context.textStyles.labelMedium?.copyWith(color: onColor),
      ),
    );
  }
}

class _SchemeColors extends StatelessWidget {
  const _SchemeColors();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _Swatch('primary', c.primary, c.onPrimary),
        _Swatch('primaryContainer', c.primaryContainer, c.onPrimaryContainer),
        _Swatch('secondary', c.secondary, c.onSecondary),
        _Swatch(
          'secondaryContainer',
          c.secondaryContainer,
          c.onSecondaryContainer,
        ),
        _Swatch('tertiary', c.tertiary, c.onTertiary),
        _Swatch(
          'tertiaryContainer',
          c.tertiaryContainer,
          c.onTertiaryContainer,
        ),
        _Swatch('surface', c.surface, c.onSurface),
        _Swatch('surfaceContainer', c.surfaceContainer, c.onSurface),
        _Swatch(
          'surfaceVariant',
          c.surfaceContainerHighest,
          c.onSurfaceVariant,
        ),
        _Swatch('outline', c.outline, c.surface),
        _Swatch('inverseSurface', c.inverseSurface, c.onInverseSurface),
      ],
    );
  }
}

class _SemanticColors extends StatelessWidget {
  const _SemanticColors();

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final roles = {
      'success': s.success,
      'warning': s.warning,
      'error': s.error,
      'info': s.info,
    };
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final MapEntry(key: name, value: role) in roles.entries) ...[
          _Swatch(name, role.color, role.onColor),
          _Swatch('${name}Container', role.container, role.onContainer),
        ],
      ],
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    final styles = {
      'displayLarge': t.displayLarge,
      'displayMedium': t.displayMedium,
      'displaySmall': t.displaySmall,
      'headlineLarge': t.headlineLarge,
      'headlineMedium': t.headlineMedium,
      'headlineSmall': t.headlineSmall,
      'titleLarge': t.titleLarge,
      'titleMedium': t.titleMedium,
      'titleSmall': t.titleSmall,
      'bodyLarge': t.bodyLarge,
      'bodyMedium': t.bodyMedium,
      'bodySmall': t.bodySmall,
      'labelLarge': t.labelLarge,
      'labelMedium': t.labelMedium,
      'labelSmall': t.labelSmall,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(key: name, value: style) in styles.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '$name ${style?.fontSize?.toStringAsFixed(0)}',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _SpacingScale extends StatelessWidget {
  const _SpacingScale();

  @override
  Widget build(BuildContext context) {
    const tokens = {
      'xxs': AppSpacing.xxs,
      'xs': AppSpacing.xs,
      'sm': AppSpacing.sm,
      'md': AppSpacing.md,
      'lg': AppSpacing.lg,
      'xl': AppSpacing.xl,
      'xxl': AppSpacing.xxl,
    };
    return Column(
      children: [
        for (final MapEntry(key: name, value: value) in tokens.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    '$name ${value.toStringAsFixed(0)}',
                    style: context.textStyles.labelMedium,
                  ),
                ),
                Container(
                  width: value,
                  height: AppSpacing.md,
                  color: context.colors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RadiusScale extends StatelessWidget {
  const _RadiusScale();

  @override
  Widget build(BuildContext context) {
    const tokens = {
      'sm': AppRadius.smAll,
      'md': AppRadius.mdAll,
      'lg': AppRadius.lgAll,
      'xl': AppRadius.xlAll,
    };
    return Wrap(
      spacing: AppSpacing.md,
      children: [
        for (final MapEntry(key: name, value: radius) in tokens.entries)
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: radius,
            ),
            child: Text(
              name,
              style: context.textStyles.labelMedium?.copyWith(
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final variant in AppButtonVariant.values)
              AppButton(
                label: variant.name,
                variant: variant,
                onPressed: _noop,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final size in AppButtonSize.values)
              AppButton(
                label: size.name,
                size: size,
                icon: Icons.add,
                onPressed: _noop,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(label: 'Disabled', onPressed: null),
            AppButton(label: 'Saving', isLoading: true, onPressed: _noop),
            AppButton(
              label: 'Deleting',
              variant: AppButtonVariant.destructive,
              isLoading: true,
              onPressed: _noop,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const AppButton(
          label: 'Full width',
          icon: Icons.login,
          isFullWidth: true,
          onPressed: _noop,
        ),
      ],
    );
  }
}

class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppCard(child: Text('Plain card with default padding.')),
        AppCard(
          header: const Text('Mobile development'),
          footer: const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(
              label: 'Details',
              variant: AppButtonVariant.text,
              onPressed: _noop,
            ),
          ),
          onTap: _noop,
          child: Text(
            'Card with header, footer and an ink ripple on tap.',
            style: context.textStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _Loaders extends StatelessWidget {
  const _Loaders();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            AppLoader(size: AppLoaderSize.small),
            SizedBox(width: AppSpacing.lg),
            AppLoader(),
            SizedBox(width: AppSpacing.lg),
            AppLoader(size: AppLoaderSize.large),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: AppLoader(message: 'Loading timetable…')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            AppSkeleton.circle(size: AppSizes.iconLg),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 160),
                  SizedBox(height: AppSpacing.sm),
                  AppSkeleton(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: AppLoadingOverlay(
            isLoading: true,
            message: 'Saving…',
            child: Container(color: context.colors.surfaceContainer),
          ),
        ),
      ],
    );
  }
}
