import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/presentation/cubit/course_cubit.dart';

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CourseCubit>(
      create: (_) => getIt<CourseCubit>(),
      child: const CourseView(),
    );
  }
}

class CourseView extends StatefulWidget {
  const CourseView({super.key});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _semesterController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CourseCubit>().create(
      name: _nameController.text,
      code: _codeController.text,
      semester: _semesterController.text,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseCubit>().load();
    });
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? 'This field is required'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: BlocConsumer<CourseCubit, CourseState>(
        listener: (context, state) {
          if (state case CourseError(:final message)) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
          if (state is CourseCreated) {
            _nameController.clear();
            _codeController.clear();
            _semesterController.clear();
            context.read<CourseCubit>().load();
          }
        },
        builder: (context, state) {
          final isCreating = state is CourseCreating;
          final courses = switch (state) {
            CourseLoaded(:final courses) => courses,
            CourseCreated(:final courses) => courses,
            CourseUpdating(:final courses) => courses,
            CourseError(:final courses) => courses,
            _ => const <Course>[],
          };
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Create a course',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('Add a course to the university catalogue.'),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Course name',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Course code',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _semesterController,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      validator: _required,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isCreating ? null : _submit,
                      child: isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create course'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Course list',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (state is CourseLoading)
                const Center(child: CircularProgressIndicator())
              else if (courses.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.school_outlined),
                    title: Text('No courses'),
                  ),
                )
              else
                for (final course in courses)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        course.isSuspended
                            ? Icons.pause_circle_outline
                            : Icons.school_outlined,
                      ),
                      title: Text(course.name),
                      subtitle: Text(
                        '${course.code} · ${course.semester}'
                        '${course.isSuspended ? ' · Suspended' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: course.isSuspended
                                ? 'Restore course'
                                : 'Suspend course',
                            icon: Icon(
                              course.isSuspended
                                  ? Icons.play_circle_outline
                                  : Icons.pause_circle_outline,
                            ),
                            onPressed: () =>
                                context.read<CourseCubit>().suspend(course),
                          ),
                          IconButton(
                            tooltip: 'Delete course',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDelete(context, course),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete course'),
        content: Text('Permanently delete ${course.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CourseCubit>().delete(course);
    }
  }
}
