import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/home/presentation/cubit/home_cubit.dart';
import 'package:uniconnect/features/home/presentation/widgets/welcome_item_card.dart';

/// Home screen of a [role]. Provides its [HomeCubit] from get_it.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => getIt<HomeCubit>()..load(role),
      child: HomeView(role: role),
    );
  }
}

/// UI of the home screen. Reads the [HomeCubit] from the widget tree, which
/// makes it easy to test with a mocked cubit.
class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UniConnect')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeLoading() => const Center(child: CircularProgressIndicator()),
            HomeError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<HomeCubit>().load(role),
            ),
            HomeLoaded(:final items) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Welcome to UniConnect',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${role.label} space',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                for (final item in items) WelcomeItemCard(item: item),
              ],
            ),
          };
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
