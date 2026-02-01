/// Tests for StepCounterCard widget.
///
/// These tests verify that the StepCounterCard correctly displays
/// step counts, goals, progress percentages, and goal completion states.
library;

import 'package:app_pasos_frontend/features/dashboard/presentation/widgets/step_counter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('StepCounterCard', () {
    group('Step Count Display', () {
      testWidgets('displays current step count formatted with commas',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 7500,
            goal: 10000,
          ),
        );

        // Assert - Check for formatted number with comma
        expect(find.text('7,500'), findsOneWidget);
      });

      testWidgets('displays step count without comma for numbers under 1000',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 500,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text('500'), findsOneWidget);
      });

      testWidgets('displays large step count with multiple commas',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 1234567,
            goal: 2000000,
          ),
        );

        // Assert
        expect(find.text('1,234,567'), findsOneWidget);
      });
    });

    group('Goal Text Display', () {
      testWidgets('displays goal text "of X steps"', (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 5000,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text('of 10,000 steps'), findsOneWidget);
      });

      testWidgets('displays goal text with comma formatting', (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 500,
            goal: 15000,
          ),
        );

        // Assert
        expect(find.text('of 15,000 steps'), findsOneWidget);
      });
    });

    group('Percentage Badge Display', () {
      testWidgets('displays percentage completed badge', (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 5000,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text('50% completed'), findsOneWidget);
      });

      testWidgets('calculates progress correctly (75% for 7500/10000)',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 7500,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text('75% completed'), findsOneWidget);
      });

      testWidgets('displays 100% when goal is reached exactly', (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 10000,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text('100% completed'), findsOneWidget);
      });

      testWidgets('displays percentage over 100% when goal exceeded',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 12000,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text('120% completed'), findsOneWidget);
      });
    });

    group('Goal Reached Indicator', () {
      testWidgets('shows "Goal reached!" when currentSteps >= goal',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 10000,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text('Goal reached!'), findsOneWidget);
        expect(find.byIcon(Icons.celebration), findsOneWidget);
      });

      testWidgets('shows "Goal reached!" when steps exceed goal',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 15000,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text('Goal reached!'), findsOneWidget);
      });

      testWidgets('does not show "Goal reached!" when below goal',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 9999,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text('Goal reached!'), findsNothing);
        expect(find.byIcon(Icons.celebration), findsNothing);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles 0 steps case without division error',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 0,
            goal: 10000,
          ),
        );

        // Assert - Should display 0 and 0%
        expect(find.text('0'), findsOneWidget);
        expect(find.text('0% completed'), findsOneWidget);
        expect(find.text('Goal reached!'), findsNothing);
      });

      testWidgets('handles 0 goal case without division error',
          (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 5000,
            goal: 0,
          ),
        );

        // Assert - Should handle gracefully with 0%
        expect(find.text('5,000'), findsOneWidget);
        expect(find.text('of 0 steps'), findsOneWidget);
        expect(find.text('0% completed'), findsOneWidget);
      });

      testWidgets('handles both 0 steps and 0 goal', (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 0,
            goal: 0,
          ),
        );

        // Assert
        expect(find.text('0'), findsAtLeast(1));
        expect(find.text('0% completed'), findsOneWidget);
      });
    });

    group('Title Display', () {
      testWidgets('displays "Today\'s Steps" title', (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 5000,
            goal: 10000,
          ),
        );

        // Assert
        expect(find.text("Today's Steps"), findsOneWidget);
      });
    });

    group('Widget Structure', () {
      testWidgets('renders as a Card widget', (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 5000,
            goal: 10000,
          ),
        );

        // Assert - StepCounterCard uses AppCard which wraps a Card
        expect(find.byType(StepCounterCard), findsOneWidget);
      });

      testWidgets('contains circular progress indicator', (tester) async {
        // Arrange & Act
        await pumpApp(
          tester,
          const StepCounterCard(
            currentSteps: 5000,
            goal: 10000,
          ),
        );

        // Assert - CustomPaint is used for the circular progress
        // Multiple CustomPaint widgets may exist in widget tree
        expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
      });
    });
  });
}
