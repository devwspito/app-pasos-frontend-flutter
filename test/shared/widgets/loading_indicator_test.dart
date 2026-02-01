/// Widget tests for [LoadingIndicator].
///
/// Tests cover:
/// - Rendering CircularProgressIndicator correctly
/// - Displaying optional message text
/// - Overlay mode with semi-transparent background
/// - Custom size parameter
library;

import 'package:app_pasos_frontend/core/theme/app_theme.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('LoadingIndicator', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      await pumpAppWithoutSettle(
        tester,
        const Scaffold(
          body: LoadingIndicator(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows message text when message parameter provided',
        (tester) async {
      const testMessage = 'Loading data...';

      await pumpAppWithoutSettle(
        tester,
        const Scaffold(
          body: LoadingIndicator(message: testMessage),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show message when null', (tester) async {
      await pumpAppWithoutSettle(
        tester,
        const Scaffold(
          body: LoadingIndicator(),
        ),
      );

      // Should only find the CircularProgressIndicator, no text widget
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Verify no Text widget is rendered as a direct child
      expect(
        find.descendant(
          of: find.byType(LoadingIndicator),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
    });

    testWidgets('overlay mode shows semi-transparent background',
        (tester) async {
      await pumpAppWithoutSettle(
        tester,
        const Scaffold(
          body: LoadingIndicator(
            overlay: true,
            message: 'Please wait...',
          ),
        ),
      );

      // In overlay mode, should have ColoredBox with scrim color
      expect(find.byType(ColoredBox), findsOneWidget);

      // Verify the ColoredBox has semi-transparent background
      final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(coloredBox.color.opacity, lessThan(1.0));
      expect(coloredBox.color.opacity, greaterThan(0.0));

      // Should also have the indicator and message
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('respects custom size parameter', (tester) async {
      const customSize = 60.0;

      await pumpAppWithoutSettle(
        tester,
        const Scaffold(
          body: LoadingIndicator(size: customSize),
        ),
      );

      // Find the SizedBox that wraps the CircularProgressIndicator
      final sizedBoxFinder = find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      );

      expect(sizedBoxFinder, findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('uses default size of 40 when not specified', (tester) async {
      await pumpAppWithoutSettle(
        tester,
        const Scaffold(
          body: LoadingIndicator(),
        ),
      );

      // Find the SizedBox that wraps the CircularProgressIndicator
      final sizedBoxFinder = find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      );

      expect(sizedBoxFinder, findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, equals(40.0));
      expect(sizedBox.height, equals(40.0));
    });

    testWidgets('overlay mode renders container with rounded corners',
        (tester) async {
      await pumpAppWithoutSettle(
        tester,
        const Scaffold(
          body: LoadingIndicator(overlay: true),
        ),
      );

      // Find the Container that has the decoration with rounded corners
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).borderRadius != null,
      );

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('non-overlay mode centers the indicator', (tester) async {
      await pumpAppWithoutSettle(
        tester,
        const Scaffold(
          body: LoadingIndicator(),
        ),
      );

      // In non-overlay mode, the widget should be wrapped in Center
      expect(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(Center),
        ),
        findsWidgets,
      );
    });

    testWidgets('can use custom color for indicator', (tester) async {
      const customColor = Colors.red;

      await pumpAppWithoutSettle(
        tester,
        const Scaffold(
          body: LoadingIndicator(color: customColor),
        ),
      );

      // Verify CircularProgressIndicator has the custom color
      final indicator = tester.widget<ProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(indicator.valueColor, isA<AlwaysStoppedAnimation<Color>>());
      final animation = indicator.valueColor! as AlwaysStoppedAnimation<Color>;
      expect(animation.value, equals(customColor));
    });
  });
}
