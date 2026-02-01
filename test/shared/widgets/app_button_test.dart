/// Widget tests for [AppButton].
///
/// Tests cover:
/// - Rendering text labels correctly
/// - Handling tap callbacks
/// - Loading state with CircularProgressIndicator
/// - Disabled states (onPressed null and isLoading true)
/// - Different ButtonVariant styles
/// - Leading and trailing icons
library;

import 'package:app_pasos_frontend/core/theme/app_theme.dart';
import 'package:app_pasos_frontend/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_test_helpers.dart';

/// Pumps a widget without pumpAndSettle - useful for loading states
/// that have infinite animations like CircularProgressIndicator.
Future<void> pumpAppWithoutSettle(
  WidgetTester tester,
  Widget child,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
  await tester.pump();
}

void main() {
  group('AppButton', () {
    testWidgets('renders button with correct text label', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: AppButton(
            text: 'Submit',
            onPressed: null,
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('handles tap callback when pressed', (tester) async {
      var tapped = false;

      await pumpApp(
        tester,
        Scaffold(
          body: AppButton(
            text: 'Click Me',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true',
        (tester) async {
      // Use pumpAppWithoutSettle because CircularProgressIndicator
      // animates infinitely and pumpAndSettle would timeout
      await pumpAppWithoutSettle(
        tester,
        Scaffold(
          body: AppButton(
            text: 'Loading',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Text should not be visible when loading
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('button is disabled when onPressed is null', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: AppButton(
            text: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );

      // Verify the ElevatedButton is actually disabled
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('button is disabled when isLoading is true', (tester) async {
      var tapped = false;

      // Use pumpAppWithoutSettle because CircularProgressIndicator
      // animates infinitely and pumpAndSettle would timeout
      await pumpAppWithoutSettle(
        tester,
        Scaffold(
          body: AppButton(
            text: 'Loading Button',
            onPressed: () {
              tapped = true;
            },
            isLoading: true,
          ),
        ),
      );

      // Try to tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify callback was NOT invoked
      expect(tapped, isFalse);

      // Verify the ElevatedButton is disabled
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(elevatedButton.onPressed, isNull);
    });

    group('renders with different ButtonVariant styles', () {
      testWidgets('renders primary variant (default) as ElevatedButton',
          (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'Primary',
              onPressed: () {},
              // variant: ButtonVariant.primary is the default
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Primary'), findsOneWidget);
      });

      testWidgets('renders secondary variant as ElevatedButton',
          (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'Secondary',
              onPressed: () {},
              variant: ButtonVariant.secondary,
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Secondary'), findsOneWidget);
      });

      testWidgets('renders outline variant as OutlinedButton', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'Outline',
              onPressed: () {},
              variant: ButtonVariant.outline,
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
        expect(find.text('Outline'), findsOneWidget);
      });

      testWidgets('renders text variant as TextButton', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'Text Button',
              onPressed: () {},
              variant: ButtonVariant.text,
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
        expect(find.text('Text Button'), findsOneWidget);
      });
    });

    group('renders icons', () {
      testWidgets('renders leading icon when provided', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'With Leading',
              onPressed: () {},
              leadingIcon: Icons.add,
            ),
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('With Leading'), findsOneWidget);
      });

      testWidgets('renders trailing icon when provided', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'With Trailing',
              onPressed: () {},
              trailingIcon: Icons.arrow_forward,
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
        expect(find.text('With Trailing'), findsOneWidget);
      });

      testWidgets('renders both leading and trailing icons', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'Both Icons',
              onPressed: () {},
              leadingIcon: Icons.star,
              trailingIcon: Icons.chevron_right,
            ),
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.text('Both Icons'), findsOneWidget);
      });

      testWidgets('does not render icons when loading', (tester) async {
        // Use pumpAppWithoutSettle because CircularProgressIndicator
        // animates infinitely and pumpAndSettle would timeout
        await pumpAppWithoutSettle(
          tester,
          Scaffold(
            body: AppButton(
              text: 'Loading',
              onPressed: () {},
              leadingIcon: Icons.add,
              trailingIcon: Icons.remove,
              isLoading: true,
            ),
          ),
        );

        // Icons should not appear during loading
        expect(find.byIcon(Icons.add), findsNothing);
        expect(find.byIcon(Icons.remove), findsNothing);
        // CircularProgressIndicator should appear instead
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('button sizes', () {
      testWidgets('renders with small size', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'Small',
              onPressed: () {},
              size: ButtonSize.small,
            ),
          ),
        );

        expect(find.text('Small'), findsOneWidget);
      });

      testWidgets('renders with medium size (default)', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'Medium',
              onPressed: () {},
              // size: ButtonSize.medium is the default
            ),
          ),
        );

        expect(find.text('Medium'), findsOneWidget);
      });

      testWidgets('renders with large size', (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: AppButton(
              text: 'Large',
              onPressed: () {},
              size: ButtonSize.large,
            ),
          ),
        );

        expect(find.text('Large'), findsOneWidget);
      });
    });

    testWidgets('renders full width when fullWidth is true', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: AppButton(
                text: 'Full Width',
                onPressed: () {},
                fullWidth: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Full Width'), findsOneWidget);
      // Verify SizedBox wrapper with double.infinity exists
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, equals(double.infinity));
    });
  });
}
