import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/dev/ui_gallery_page.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/widgets.dart';

void main() {
  Future<void> pumpGallery(WidgetTester tester, ThemeMode mode) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: const UiGalleryPage(),
      ),
    );
    await tester.pump();
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('renders every section in ${mode.name} mode', (tester) async {
      await pumpGallery(tester, mode);

      final list = find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first;
      for (final text in [
        'Saving…',
        'No lectures today',
        'Check your connection and try again.',
      ]) {
        await tester.scrollUntilVisible(find.text(text), 300, scrollable: list);
        expect(find.text(text), findsOneWidget);
      }
      expect(find.byType(ErrorState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('switches between light and dark', (tester) async {
    await pumpGallery(tester, ThemeMode.light);

    expect(
      Theme.of(tester.element(find.text('UI gallery'))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byTooltip('Show dark theme'));
    await tester.pump();

    expect(
      Theme.of(tester.element(find.text('UI gallery'))).brightness,
      Brightness.dark,
    );
    expect(find.byTooltip('Show light theme'), findsOneWidget);
  });
}
