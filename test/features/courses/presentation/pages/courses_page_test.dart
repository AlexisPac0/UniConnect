import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/widgets.dart';
import 'package:uniconnect/features/courses/domain/entities/semester.dart';
import 'package:uniconnect/features/courses/domain/usecases/create_course.dart';
import 'package:uniconnect/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:uniconnect/features/courses/presentation/pages/courses_page.dart';

import '../../fixtures.dart';

class MockCoursesCubit extends MockCubit<CoursesState>
    implements CoursesCubit {}

void main() {
  late MockCoursesCubit cubit;

  setUpAll(() {
    registerFallbackValue(tTypedDatabases);
    registerFallbackValue(tAlgorithms);
  });

  setUp(() {
    cubit = MockCoursesCubit();
    when(() => cubit.load()).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester, CoursesState state) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider<CoursesCubit>.value(
          value: cubit,
          child: const CoursesView(),
        ),
      ),
    );
  }

  testWidgets('shows a loader while loading', (tester) async {
    await pumpView(tester, const CoursesLoading());

    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.text('Add course'), findsNothing);
  });

  testWidgets('a load error can be retried', (tester) async {
    await pumpView(tester, const CoursesLoadError('Offline'));

    expect(find.text('Offline'), findsOneWidget);
    await tester.tap(find.text('Retry'));

    verify(() => cubit.load()).called(1);
  });

  testWidgets('shows an empty state without courses', (tester) async {
    await pumpView(tester, const CoursesLoaded([]));

    expect(find.text('No courses yet'), findsOneWidget);
  });

  testWidgets('lists the courses with their code and semester', (tester) async {
    await pumpView(tester, const CoursesLoaded([tAlgorithms, tMobile]));

    expect(find.text('Algorithms'), findsOneWidget);
    expect(find.text('ALG201 · 2026-FALL'), findsOneWidget);
    expect(find.text('Mobile Development'), findsOneWidget);
  });

  group('create', () {
    Future<void> openForm(WidgetTester tester) async {
      await pumpView(tester, const CoursesLoaded([tAlgorithms]));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
    }

    Future<void> fillForm(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Databases',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Code'),
        'db101',
      );
    }

    testWidgets('empty fields are required', (tester) async {
      await openForm(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Create'));
      await tester.pump();

      // The semester is preselected: only the name and code are missing.
      expect(find.text('Required'), findsNWidgets(2));
      verifyNever(() => cubit.create(any()));
    });

    testWidgets('closes the form once the course is created', (tester) async {
      when(() => cubit.create(any())).thenAnswer((_) async => null);
      await openForm(tester);
      await fillForm(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Create'));
      await tester.pumpAndSettle();

      final values =
          verify(() => cubit.create(captureAny())).captured.single
              as CourseParams;
      expect(
        (values.name, values.code, values.semester),
        ('Databases', 'db101', Semesters.current(DateTime.now())),
      );
      expect(find.text('New course'), findsNothing);
    });

    testWidgets('keeps the form open with the error on failure', (
      tester,
    ) async {
      when(
        () => cubit.create(any()),
      ).thenAnswer((_) async => 'A course with this code already exists.');
      await openForm(tester);
      await fillForm(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Create'));
      await tester.pumpAndSettle();

      expect(find.text('New course'), findsOneWidget);
      expect(
        find.text('A course with this code already exists.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('edit opens the form filled with the course', (tester) async {
    when(() => cubit.update(any(), any())).thenAnswer((_) async => null);
    await pumpView(tester, const CoursesLoaded([tAlgorithms]));

    await tester.tap(find.byTooltip('Edit ALG201'));
    await tester.pumpAndSettle();

    expect(find.text('Edit course'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Algorithms'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'Save'));
    await tester.pumpAndSettle();

    verify(() => cubit.update('c1', any())).called(1);
  });

  group('delete', () {
    Future<void> askToDelete(WidgetTester tester) async {
      await pumpView(tester, const CoursesLoaded([tAlgorithms]));
      await tester.tap(find.byTooltip('Delete ALG201'));
      await tester.pumpAndSettle();
    }

    testWidgets('asks for confirmation, then deletes', (tester) async {
      when(() => cubit.delete(any())).thenAnswer((_) async => null);
      await askToDelete(tester);

      expect(find.text('Delete course?'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => cubit.delete(tAlgorithms)).called(1);
      expect(find.text('ALG201 deleted.'), findsOneWidget);
    });

    testWidgets('cancelling keeps the course', (tester) async {
      await askToDelete(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => cubit.delete(any()));
    });

    testWidgets('shows the error when deleting fails', (tester) async {
      when(
        () => cubit.delete(any()),
      ).thenAnswer((_) async => 'You are not allowed to perform this action.');
      await askToDelete(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(
        find.text('You are not allowed to perform this action.'),
        findsOneWidget,
      );
    });
  });
}
