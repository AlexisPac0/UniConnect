import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/app_button.dart';

/// Centered message for a screen or list with nothing to show: an [icon]
/// (or a custom [illustration]), a [title], an optional [message] and an
/// optional action button.
///
/// The action button is shown only when both [actionLabel] and [onAction]
/// are set.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;

  /// Replaces [icon] when set (an image, an icon with another colour…).
  final Widget? illustration;

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child:
                  illustration ??
                  Icon(
                    icon,
                    size: AppSizes.iconLg,
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              header: true,
              child: Text(
                title,
                style: textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            if (message case final message?) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if ((actionLabel, onAction) case (
              final label?,
              final onPressed?,
            )) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: label, onPressed: onPressed),
            ],
          ],
        ),
      ),
    );
  }
}
