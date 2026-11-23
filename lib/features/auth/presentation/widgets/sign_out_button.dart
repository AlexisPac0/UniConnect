import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/features/auth/presentation/cubit/sign_out_cubit.dart';

/// "Log out" button for an `AppBar`. Provides its [SignOutCubit] from get_it.
///
/// It never navigates: once signed out, Firebase Auth emits `null`, the
/// `SessionController` signs the `AppSession` out, and the router, which
/// listens to the session, redirects to the login screen.
class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignOutCubit>(
      create: (_) => getIt<SignOutCubit>(),
      child: const SignOutButtonView(),
    );
  }
}

/// UI of [SignOutButton]. Reads the [SignOutCubit] from the widget tree, which
/// makes it easy to test with a mocked cubit.
class SignOutButtonView extends StatelessWidget {
  const SignOutButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignOutCubit, SignOutState>(
      listenWhen: (_, state) => state is SignOutError,
      listener: (context, state) {
        if (state is! SignOutError) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message)));
      },
      builder: (context, state) {
        return IconButton(
          tooltip: 'Log out',
          icon: const Icon(Icons.logout),
          onPressed: state is SignOutInProgress
              ? null
              : () => _confirmAndSignOut(context),
        );
      },
    );
  }

  Future<void> _confirmAndSignOut(BuildContext context) async {
    final cubit = context.read<SignOutCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to use UniConnect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.signOut();
  }
}
