import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/widgets.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';

/// Saves the [CourseParams] typed in a [CourseFormDialog]; returns the error
/// message of a failure, or `null` on success.
typedef CourseFormSubmit = Future<String?> Function(CourseParams values);

/// Opens the course form: empty to create a course, filled with [course] to
/// edit it. The dialog closes once [onSubmit] succeeds, and shows its error
/// otherwise.
Future<void> showCourseFormDialog(
  BuildContext context, {
  Course? course,
  required CourseFormSubmit onSubmit,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => CourseFormDialog(course: course, onSubmit: onSubmit),
  );
}

class CourseFormDialog extends StatefulWidget {
  const CourseFormDialog({super.key, this.course, required this.onSubmit});

  /// Course to edit, `null` to create one.
  final Course? course;
  final CourseFormSubmit onSubmit;

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.course?.name);
  late final _code = TextEditingController(text: widget.course?.code);
  late final _semester = TextEditingController(text: widget.course?.semester);
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _semester.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final error = await widget.onSubmit(
      CourseParams(
        name: _name.text,
        code: _code.text,
        semester: _semester.text,
      ),
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSaving = false;
        _error = error;
      });
    }
  }

  static String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit course' : 'New course'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_name, 'Name', 'Mobile Application Development'),
              const SizedBox(height: AppSpacing.md),
              _field(_code, 'Code', 'CS302'),
              const SizedBox(height: AppSpacing.md),
              _field(_semester, 'Semester', '2026-FALL', isLast: true),
              if (_error case final error?) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  error,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: isEditing ? 'Save' : 'Create',
          isLoading: _isSaving,
          onPressed: _submit,
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool isLast = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      decoration: InputDecoration(labelText: label, hintText: hint),
      textCapitalization: controller == _code
          ? TextCapitalization.characters
          : TextCapitalization.sentences,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: isLast ? (_) => _submit() : null,
      validator: _required,
    );
  }
}
