import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/theme.dart';

/// Diameter of an [AppLoader].
enum AppLoaderSize { small, medium, large }

/// Centered progress spinner, with an optional [message] below it.
///
/// Use it for a loading screen body (`body: const AppLoader()`) or inline
/// with [AppLoaderSize.small]. To block a screen that is already shown, use
/// [AppLoadingOverlay].
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size = AppLoaderSize.medium,
    this.message,
    this.semanticsLabel = 'Loading',
  });

  final AppLoaderSize size;
  final String? message;

  /// Read by screen readers when there is no [message].
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final dimension = switch (size) {
      AppLoaderSize.small => AppSizes.loaderSm,
      AppLoaderSize.medium => AppSizes.loaderMd,
      AppLoaderSize.large => AppSizes.loaderLg,
    };

    final spinner = SizedBox.square(
      dimension: dimension,
      child: CircularProgressIndicator(
        strokeWidth: size == AppLoaderSize.small ? 2 : 4,
        semanticsLabel: message == null ? semanticsLabel : null,
      ),
    );

    return Center(
      child: message == null
          ? spinner
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(child: spinner),
                const SizedBox(height: AppSpacing.md),
                Text(
                  message!,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

/// Shows [child] and, while [isLoading], covers it with a scrim and an
/// [AppLoader] that blocks every tap (e.g. while a form is submitting).
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) ...[
          Positioned.fill(
            child: ModalBarrier(
              dismissible: false,
              color: context.colors.scrim.withValues(alpha: 0.32),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppLoader(message: message),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Pulsing placeholder box shown in place of content that is loading
/// (skeleton screens), so the layout does not jump when data arrives.
///
/// The pulse stops when the platform asks to reduce animations. Hidden from
/// screen readers: announce the loading state elsewhere.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = AppSpacing.md,
    this.borderRadius = AppRadius.smAll,
  }) : _shape = BoxShape.rectangle;

  /// A circular placeholder, e.g. for an avatar.
  const AppSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = null,
      _shape = BoxShape.circle;

  /// Defaults to the width of the parent.
  final double? width;
  final double height;

  /// Corner radius of a rectangular skeleton.
  final BorderRadius? borderRadius;

  final BoxShape _shape;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.4,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            shape: widget._shape,
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}
