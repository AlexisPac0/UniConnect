import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/empty_state.dart';

/// Centered error message with an optional retry button. The error
/// counterpart of [EmptyState], with the same layout.
///
/// The retry button is shown only when [onRetry] is set.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: title,
      message: message,
      illustration: Icon(
        Icons.error_outline,
        size: AppSizes.iconLg,
        color: context.colors.error,
      ),
      actionLabel: retryLabel,
      onAction: onRetry,
    );
  }
}
