import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/app_loader.dart';

import '../../helpers/pump_themed.dart';

void main() {
  group('AppLoader', () {
    testWidgets('shows a labelled spinner', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpThemed(tester, const AppLoader());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('shows the message', (tester) async {
      await pumpThemed(tester, const AppLoader(message: 'Loading timetable'));

      expect(find.text('Loading timetable'), findsOneWidget);
    });

    testWidgets('sizes follow the tokens', (tester) async {
      final sizes = {
        AppLoaderSize.small: AppSizes.loaderSm,
        AppLoaderSize.medium: AppSizes.loaderMd,
        AppLoaderSize.large: AppSizes.loaderLg,
      };
      for (final MapEntry(key: size, value: dimension) in sizes.entries) {
        await pumpThemed(tester, AppLoader(size: size));

        expect(
          tester.getSize(find.byType(CircularProgressIndicator)),
          Size.square(dimension),
        );
      }
    });
  });

  group('AppLoadingOverlay', () {
    testWidgets('blocks taps while loading', (tester) async {
      var taps = 0;
      await pumpThemed(
        tester,
        AppLoadingOverlay(
          isLoading: true,
          child: Center(
            child: TextButton(
              onPressed: () => taps++,
              child: const Text('Tap'),
            ),
          ),
        ),
      );

      expect(find.byType(AppLoader), findsOneWidget);
      await tester.tap(find.text('Tap'), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('shows only the child when not loading', (tester) async {
      var taps = 0;
      await pumpThemed(
        tester,
        AppLoadingOverlay(
          isLoading: false,
          child: Center(
            child: TextButton(
              onPressed: () => taps++,
              child: const Text('Tap'),
            ),
          ),
        ),
      );

      expect(find.byType(AppLoader), findsNothing);
      await tester.tap(find.text('Tap'));
      expect(taps, 1);
    });
  });

  group('AppSkeleton', () {
    testWidgets('renders a box of the given size', (tester) async {
      await pumpThemed(
        tester,
        const Center(child: AppSkeleton(width: 120, height: 20)),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.getSize(find.byType(AppSkeleton)), const Size(120, 20));
    });

    testWidgets('does not pulse when animations are disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: AppSkeleton.circle(size: 40)),
          ),
        ),
      );

      // Settles: no repeating animation is running.
      await tester.pumpAndSettle();
      expect(find.byType(AppSkeleton), findsOneWidget);
    });
  });
}
