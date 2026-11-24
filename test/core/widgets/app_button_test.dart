import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/core/theme/theme.dart';
import 'package:uniconnect/core/widgets/app_button.dart';

import '../../helpers/pump_themed.dart';

void main() {
  Future<void> pumpButton(WidgetTester tester, AppButton button) {
    return pumpThemed(tester, Center(child: button));
  }

  group('variants render the matching Material button', () {
    final expected = {
      AppButtonVariant.primary: FilledButton,
      AppButtonVariant.secondary: FilledButton,
      AppButtonVariant.outlined: OutlinedButton,
      AppButtonVariant.text: TextButton,
      AppButtonVariant.destructive: FilledButton,
    };
    expected.forEach((variant, type) {
      testWidgets(variant.name, (tester) async {
        await pumpButton(
          tester,
          AppButton(label: 'Go', variant: variant, onPressed: () {}),
        );

        expect(find.byType(type), findsOneWidget);
        expect(find.text('Go'), findsOneWidget);
      });
    });
  });

  testWidgets('destructive uses the error colour', (tester) async {
    await pumpButton(
      tester,
      AppButton(
        label: 'Delete',
        variant: AppButtonVariant.destructive,
        onPressed: () {},
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      button.style?.backgroundColor?.resolve({}),
      AppTheme.light.colorScheme.error,
    );
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var taps = 0;
    await pumpButton(tester, AppButton(label: 'Go', onPressed: () => taps++));

    await tester.tap(find.byType(AppButton));

    expect(taps, 1);
  });

  testWidgets('loading shows a spinner and ignores taps', (tester) async {
    var taps = 0;
    await pumpButton(
      tester,
      AppButton(
        label: 'Save',
        icon: Icons.check,
        isLoading: true,
        onPressed: () => taps++,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.text('Save'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.tap(find.byType(AppButton));
    expect(taps, 0);
  });

  testWidgets('is disabled without onPressed', (tester) async {
    await pumpButton(tester, const AppButton(label: 'Go', onPressed: null));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.enabled, isFalse);
  });

  testWidgets('shows the icon', (tester) async {
    await pumpButton(
      tester,
      AppButton(label: 'Add', icon: Icons.add, onPressed: () {}),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('full width stretches to the parent', (tester) async {
    await pumpThemed(
      tester,
      SizedBox(
        width: 300,
        child: AppButton(label: 'Go', isFullWidth: true, onPressed: () {}),
      ),
    );

    expect(tester.getSize(find.byType(FilledButton)).width, 300);
  });

  group('sizes', () {
    final heights = {
      AppButtonSize.small: AppSizes.buttonHeightSm,
      AppButtonSize.medium: AppSizes.buttonHeightMd,
      AppButtonSize.large: AppSizes.buttonHeightLg,
    };
    heights.forEach((size, height) {
      testWidgets('${size.name} has a ≥ 48 dp tap target', (tester) async {
        await pumpButton(
          tester,
          AppButton(label: 'Go', size: size, onPressed: () {}),
        );

        final box = tester.getSize(find.byType(FilledButton));
        expect(box.height, greaterThanOrEqualTo(AppSizes.minTapTarget));
        expect(box.height, greaterThanOrEqualTo(height));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      });
    });
  });

  testWidgets('meets the text contrast guideline in light and dark', (
    tester,
  ) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await pumpThemed(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final variant in AppButtonVariant.values)
              AppButton(
                label: variant.name,
                variant: variant,
                onPressed: () {},
              ),
          ],
        ),
        themeMode: mode,
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
  });
}
