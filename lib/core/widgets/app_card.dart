import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/theme.dart';

/// The app's card: themed surface, radius and elevation, with an optional
/// [header] and [footer] around the [child].
///
/// When [onTap] is set, the whole card is tappable and shows an ink ripple.
/// [padding] applies around the header, child and footer; pass
/// `EdgeInsets.zero` when the child already has its own padding (for example
/// a `ListTile`).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
  });

  final Widget child;

  /// Shown above [child] in the `titleMedium` style.
  final Widget? header;

  /// Shown below [child], typically actions.
  final Widget? footer;

  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Outer margin; defaults to the card theme's margin.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (header != null || footer != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header case final header?) ...[
            DefaultTextStyle.merge(
              style: context.textStyles.titleMedium,
              child: Semantics(header: true, child: header),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          child,
          if (footer case final footer?) ...[
            const SizedBox(height: AppSpacing.md),
            footer,
          ],
        ],
      );
    }
    content = Padding(padding: padding, child: content);

    return Card(
      margin: margin,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
