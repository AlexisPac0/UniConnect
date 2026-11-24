import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/core/router/app_routes.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/widgets.dart';
import 'package:uniconnect/features/auth/presentation/widgets/sign_out_button.dart';
import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';
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
      appBar: AppBar(
        title: const Text('UniConnect'),
        actions: [
          if (kDebugMode)
            IconButton(
              tooltip: 'UI gallery',
              icon: const Icon(Icons.palette_outlined),
              onPressed: () => context.push(AppRoutes.uiGallery),
            ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SignOutButton(),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeLoading() => const AppLoader(),
            HomeError(:final message) => ErrorState(
              message: message,
              onRetry: () => context.read<HomeCubit>().load(role),
            ),
            HomeLoaded(:final items) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  'Welcome to UniConnect',
                  style: context.textStyles.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${role.label} space',
                  style: context.textStyles.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final item in items)
                  WelcomeItemCard(
                    item: item,
                    onTap: () => context.push(_routeFor(item.action)),
                  ),
              ],
            ),
          };
        },
      ),
    );
  }
}

String _routeFor(WelcomeAction action) {
  return switch (action) {
    WelcomeAction.timetable => AppRoutes.timetable,
    WelcomeAction.scanAttendance => AppRoutes.qrScan,
    WelcomeAction.myAttendance => AppRoutes.myAttendance,
    WelcomeAction.startAttendanceSession => AppRoutes.attendanceSession,
    WelcomeAction.attendanceDashboard => AppRoutes.attendanceDashboard,
    WelcomeAction.manageCourses => AppRoutes.courses,
  };
}
