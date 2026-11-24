import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/widgets.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:uniconnect/features/courses/presentation/widgets/course_form_dialog.dart';

/// Course management screen of the administrator (UC1). Provides its
/// [CoursesCubit] from get_it.
class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CoursesCubit>(
      create: (_) => getIt<CoursesCubit>()..load(),
      child: const CoursesView(),
    );
  }
}

/// UI of the course management screen. Reads the [CoursesCubit] from the
/// widget tree, which makes it easy to test with a mocked cubit.
class CoursesView extends StatelessWidget {
  const CoursesView({super.key});

  void _openForm(BuildContext context, {Course? course}) {
    final cubit = context.read<CoursesCubit>();
    showCourseFormDialog(
      context,
      course: course,
      onSubmit: (values) => course == null
          ? cubit.create(values)
          : cubit.update(course.id, values),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final cubit = context.read<CoursesCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete course?'),
        content: Text(
          '${course.name} (${course.code}) and its enrolments will be '
          'permanently deleted.',
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          AppButton(
            label: 'Delete',
            variant: AppButtonVariant.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await cubit.delete(course);
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? '${course.code} deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      floatingActionButton: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) => state is CoursesLoaded
            ? FloatingActionButton.extended(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add course'),
              )
            : const SizedBox.shrink(),
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          return switch (state) {
            CoursesLoading() => const AppLoader(),
            CoursesLoadError(:final message) => ErrorState(
              message: message,
              onRetry: () => context.read<CoursesCubit>().load(),
            ),
            CoursesLoaded(courses: []) => EmptyState(
              icon: Icons.school_outlined,
              title: 'No courses yet',
              message: 'Add the first course of the catalogue.',
              actionLabel: 'Add course',
              onAction: () => _openForm(context),
            ),
            CoursesLoaded(:final courses) => ListView.builder(
              // Leaves room for the floating button below the last course.
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl * 2,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return _CourseTile(
                  course: course,
                  onEdit: () => _openForm(context, course: course),
                  onDelete: () => _confirmDelete(context, course),
                );
              },
            ),
          };
        },
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.school_outlined),
        title: Text(course.name),
        subtitle: Text('${course.code} · ${course.semester}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Edit ${course.code}',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete ${course.code}',
              icon: Icon(Icons.delete_outline, color: context.colors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
