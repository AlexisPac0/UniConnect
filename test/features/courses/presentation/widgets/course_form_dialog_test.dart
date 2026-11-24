import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/widgets.dart';
import 'package:uniconnect/features/courses/domain/entities/course.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';
import 'package:uniconnect/features/courses/presentation/widgets/course_form_dialog.dart';

void main() {
  final today = DateTime(2026, 11, 24);

  Future<List<CourseParams>> pumpDialog(
    WidgetTester tester, {
    Course? course,
  }) async {
    final submitted = <CourseParams>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CourseFormDialog(
            course: course,
            today: today,
            onSubmit: (values) async {
              submitted.add(values);
              return null;
            },
          ),
        ),
      ),
    );
    return submitted;
  }

  testWidgets('a new course starts in the current semester', (tester) async {
    await pumpDialog(tester);

    expect(find.text('2026-FALL (current)'), findsOneWidget);
  });

  testWidgets('the semester is chosen in a list', (tester) async {
    final submitted = await pumpDialog(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Web');
    await tester.enterText(find.widgetWithText(TextFormField, 'Code'), 'WEB1');

    await tester.tap(find.text('2026-FALL (current)'));
    await tester.pumpAndSettle();
    expect(find.text('2025-SPRING'), findsOneWidget);
    expect(find.text('2027-FALL'), findsOneWidget);
    await tester.tap(find.text('2027-SPRING').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Create'));
    await tester.pump();

    expect(submitted.single.semester, '2027-SPRING');
  });

  testWidgets('keeps the semester of an older course when editing', (
    tester,
  ) async {
    final submitted = await pumpDialog(
      tester,
      course: const Course(
        id: 'c1',
        name: 'Algorithms',
        code: 'ALG201',
        semester: 'Fall 2023',
      ),
    );

    expect(find.text('Fall 2023'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Save'));
    await tester.pump();

    expect(submitted.single.semester, 'Fall 2023');
  });
}
