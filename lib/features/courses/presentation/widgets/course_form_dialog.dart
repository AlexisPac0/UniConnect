import 'package:flutter/material.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/widgets.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/entities/semester.dart';
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
  DateTime? today,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) =>
        CourseFormDialog(course: course, onSubmit: onSubmit, today: today),
  );
}

class CourseFormDialog extends StatefulWidget {
  const CourseFormDialog({
    super.key,
    this.course,
    required this.onSubmit,
    this.today,
  });

  /// Course to edit, `null` to create one.
  final Course? course;
  final CourseFormSubmit onSubmit;

  /// Date that decides the semesters offered; `DateTime.now()` by default.
  final DateTime? today;

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.course?.name);
  late final _code = TextEditingController(text: widget.course?.code);
  late final String _currentSemester = Semesters.current(_today);
  late final DateTime _today = widget.today ?? DateTime.now();

  /// A new course starts in the current semester.
  late String? _semester = widget.course?.semester ?? _currentSemester;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
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
        semester: _semester ?? '',
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
              _semesterField(),
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

  Widget _field(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      decoration: InputDecoration(labelText: label, hintText: hint),
      textCapitalization: controller == _code
          ? TextCapitalization.characters
          : TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      validator: _required,
    );
  }

  /// The semesters around today, plus the semester of the edited course if
  /// it is older or was typed in another format.
  Widget _semesterField() {
    final semesters = Semesters.around(_today);
    final edited = widget.course?.semester;
    final options = [
      if (edited != null && !semesters.contains(edited)) edited,
      ...semesters,
    ];
    return DropdownButtonFormField<String>(
      initialValue: _semester,
      decoration: const InputDecoration(labelText: 'Semester'),
      items: [
        for (final semester in options)
          DropdownMenuItem(
            value: semester,
            child: Text(
              semester == _currentSemester ? '$semester (current)' : semester,
            ),
          ),
      ],
      onChanged: _isSaving
          ? null
          : (value) => setState(() => _semester = value),
      validator: _required,
    );
  }
}
