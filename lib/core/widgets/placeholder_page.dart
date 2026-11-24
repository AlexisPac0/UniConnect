import 'package:flutter/material.dart';
import 'package:uniconnect/core/widgets/empty_state.dart';

/// Temporary screen used by routes whose feature is not implemented yet.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const EmptyState(
        icon: Icons.construction_outlined,
        title: 'Coming soon',
        message: 'This screen has not been implemented yet.',
      ),
    );
  }
}
