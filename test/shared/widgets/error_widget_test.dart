/// Widget tests for [AppErrorWidget].
///
/// Tests cover:
/// - Rendering error title text
/// - Rendering error message text
/// - Displaying default error icon
/// - Displaying custom icon when provided
/// - Showing retry button when onRetry provided
/// - Hiding retry button when onRetry is null
/// - Invoking onRetry callback when retry button tapped
library;

import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('AppErrorWidget', () {
    testWidgets('shows error title text', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: AppErrorWidget(
            message: 'Test error message',
            title: 'Custom Error Title',
          ),
        ),
      );

      expect(find.text('Custom Error Title'), findsOneWidget);
    });

    testWidgets('shows default title when not specified', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: AppErrorWidget(
            message: 'Test error message',
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows error message text', (tester) async {
      const testMessage = 'Failed to load data. Please try again.';

      await pumpApp(
        tester,
        const Scaffold(
          body: AppErrorWidget(
            message: testMessage,
          ),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('shows default error icon (Icons.error_outline)',
        (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: AppErrorWidget(
            message: 'Test error',
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows Try Again button when onRetry provided', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: AppErrorWidget(
            message: 'Test error',
            onRetry: () {},
          ),
        ),
      );

      // Verify 'Try Again' text is visible
      expect(find.text('Try Again'), findsOneWidget);
      // Verify refresh icon is visible next to the button text
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: AppErrorWidget(
            message: 'Test error',
            // onRetry is null by default
          ),
        ),
      );

      // 'Try Again' text should not be present when onRetry is null
      expect(find.text('Try Again'), findsNothing);
      // Refresh icon should also not be present
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('onRetry callback invoked when retry button tapped',
        (tester) async {
      var retryCount = 0;

      await pumpApp(
        tester,
        Scaffold(
          body: AppErrorWidget(
            message: 'Test error',
            onRetry: () {
              retryCount++;
            },
          ),
        ),
      );

      expect(retryCount, equals(0));

      // Tap the retry button
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryCount, equals(1));

      // Tap again to verify callback can be invoked multiple times
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryCount, equals(2));
    });

    testWidgets('custom icon renders when provided', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: AppErrorWidget(
            message: 'Network error',
            icon: Icons.wifi_off,
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      // Default icon should not be present
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('renders all components together correctly', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: AppErrorWidget(
            title: 'Connection Lost',
            message: 'Please check your internet connection',
            icon: Icons.cloud_off,
            onRetry: () {},
          ),
        ),
      );

      // All components should be present
      expect(find.text('Connection Lost'), findsOneWidget);
      expect(
        find.text('Please check your internet connection'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('error icon is wrapped in circular container', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: AppErrorWidget(
            message: 'Test error',
          ),
        ),
      );

      // Find the Container that wraps the icon with circular shape
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
      );

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('widget is centered', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: AppErrorWidget(
            message: 'Test error',
          ),
        ),
      );

      // The widget should be wrapped in Center
      expect(
        find.ancestor(
          of: find.byType(AppErrorWidget),
          matching: find.byType(Center),
        ).evaluate().isNotEmpty ||
            find.descendant(
              of: find.byType(AppErrorWidget),
              matching: find.byType(Center),
            ).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('retry button has refresh icon', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: AppErrorWidget(
            message: 'Test error',
            onRetry: () {},
          ),
        ),
      );

      // Verify both the refresh icon and 'Try Again' text exist
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
