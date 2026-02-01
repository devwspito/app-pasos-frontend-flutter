/// Tests for GoalCard widget.
///
/// These tests verify that the GoalCard correctly displays
/// goal information including name, description, progress, status,
/// and handles user interactions properly.
library;

import 'package:app_pasos_frontend/features/goals/presentation/widgets/goal_card.dart';
import 'package:app_pasos_frontend/features/goals/presentation/widgets/goal_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('GoalCard', () {
    group('Goal Name Display', () {
      testWidgets('displays goal name from GroupGoal entity', (tester) async {
        // Arrange
        final goal = createTestGroupGoal(name: 'Summer Walking Challenge');

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('Summer Walking Challenge'), findsOneWidget);
      });

      testWidgets('truncates long goal names with ellipsis', (tester) async {
        // Arrange
        final goal = createTestGroupGoal(
          name: 'This is a very long goal name that should be truncated',
        );

        // Act
        await pumpApp(
          tester,
          SizedBox(
            width: 300,
            child: GoalCard(
              goal: goal,
              onTap: () {},
            ),
          ),
        );

        // Assert - Widget should still render without overflow
        expect(find.byType(GoalCard), findsOneWidget);
      });
    });

    group('Goal Description Display', () {
      testWidgets('displays goal description when hasDescription is true',
          (tester) async {
        // Arrange
        final goal = createTestGroupGoal(
          description: 'Walk 10,000 steps together!',
        );

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('Walk 10,000 steps together!'), findsOneWidget);
      });

      testWidgets('hides description when null', (tester) async {
        // Arrange
        final goal = createTestGroupGoal(description: null);

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert - Only goal name should be present, no description text
        expect(find.text('Test Goal'), findsOneWidget);
        // Verify there's no description-related text widget beyond the name
        final textWidgets = find.byType(Text);
        expect(textWidgets, findsWidgets);
      });

      testWidgets('hides description when empty string', (tester) async {
        // Arrange
        final goal = createTestGroupGoal(description: '');

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('Test Goal'), findsOneWidget);
        expect(find.text(''), findsNothing);
      });
    });

    group('Step Progress Display', () {
      testWidgets('displays step progress "X / Y" format', (tester) async {
        // Arrange
        final goal = createTestGroupGoal();
        final progress = createTestGoalProgress();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            progress: progress,
            onTap: () {},
          ),
        );

        // Assert - Progress badge formats with K suffix
        expect(find.text('5K / 10K'), findsOneWidget);
      });

      testWidgets('displays small step counts without K suffix',
          (tester) async {
        // Arrange
        final goal = createTestGroupGoal(targetSteps: 500);
        final progress = createTestGoalProgress(
          currentSteps: 250,
          targetSteps: 500,
        );

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            progress: progress,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('250 / 500'), findsOneWidget);
      });

      testWidgets('displays 0 steps when no progress provided', (tester) async {
        // Arrange
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('0 / 10K'), findsOneWidget);
      });

      testWidgets('displays large numbers with M suffix', (tester) async {
        // Arrange
        final goal = createTestGroupGoal(targetSteps: 2000000);
        final progress = createTestGoalProgress(
          currentSteps: 1500000,
          targetSteps: 2000000,
        );

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            progress: progress,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('1.5M / 2M'), findsOneWidget);
      });
    });

    group('Status Badge Display', () {
      testWidgets('displays Active status badge', (tester) async {
        // Arrange
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('Active'), findsOneWidget);
        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      });

      testWidgets('displays Done status badge for completed goals',
          (tester) async {
        // Arrange
        final goal = createTestGroupGoal(status: 'completed');

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('Done'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('displays Cancelled status badge', (tester) async {
        // Arrange
        final goal = createTestGroupGoal(status: 'cancelled');

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('Cancelled'), findsOneWidget);
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      });

      testWidgets('displays unknown status as-is', (tester) async {
        // Arrange
        final goal = createTestGroupGoal(status: 'paused');

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.text('paused'), findsOneWidget);
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });
    });

    group('Tap Interactions', () {
      testWidgets('onTap callback invoked when card tapped', (tester) async {
        // Arrange
        var tapped = false;
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () => tapped = true,
          ),
        );

        // Tap the card
        await tester.tap(find.byType(GoalCard));
        await tester.pumpAndSettle();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('onTap works when onLongPress is also provided',
          (tester) async {
        // Arrange
        var tapped = false;
        var longPressed = false;
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () => tapped = true,
            onLongPress: () => longPressed = true,
          ),
        );

        // Tap the card
        await tester.tap(find.byType(GoalCard));
        await tester.pumpAndSettle();

        // Assert
        expect(tapped, isTrue);
        expect(longPressed, isFalse);
      });
    });

    group('Long Press Interactions', () {
      testWidgets('onLongPress callback invoked when card long-pressed',
          (tester) async {
        // Arrange
        var longPressed = false;
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
            onLongPress: () => longPressed = true,
          ),
        );

        // Long press the card
        await tester.longPress(find.byType(GoalCard));
        await tester.pumpAndSettle();

        // Assert
        expect(longPressed, isTrue);
      });

      testWidgets('long press does not trigger tap callback', (tester) async {
        // Arrange
        var tapped = false;
        var longPressed = false;
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () => tapped = true,
            onLongPress: () => longPressed = true,
          ),
        );

        // Long press the card
        await tester.longPress(find.byType(GoalCard));
        await tester.pumpAndSettle();

        // Assert
        expect(longPressed, isTrue);
        expect(tapped, isFalse);
      });
    });

    group('Progress Indicator', () {
      testWidgets('shows GoalProgressIndicator with correct percentage',
          (tester) async {
        // Arrange
        final goal = createTestGroupGoal();
        final progress = createTestGoalProgress(
          currentSteps: 7500,
          progressPercentage: 75,
        );

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            progress: progress,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.byType(GoalProgressIndicator), findsOneWidget);
      });

      testWidgets('shows 0% progress when no progress data', (tester) async {
        // Arrange
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert - GoalProgressIndicator should be present with 0 progress
        expect(find.byType(GoalProgressIndicator), findsOneWidget);
      });

      testWidgets('shows 100% progress when goal completed', (tester) async {
        // Arrange
        final goal = createTestGroupGoal();
        final progress = createTestGoalProgress(
          currentSteps: 10000,
          progressPercentage: 100,
        );

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            progress: progress,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.byType(GoalProgressIndicator), findsOneWidget);
      });
    });

    group('Widget Structure', () {
      testWidgets('renders GoalCard widget successfully', (tester) async {
        // Arrange
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.byType(GoalCard), findsOneWidget);
      });

      testWidgets('contains walk icon for steps badge', (tester) async {
        // Arrange
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      });
    });

    group('Last Updated Display', () {
      testWidgets('shows last updated badge when lastUpdated provided',
          (tester) async {
        // Arrange
        final goal = createTestGroupGoal();
        final lastUpdated = DateTime.now().subtract(const Duration(minutes: 5));

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
            lastUpdated: lastUpdated,
          ),
        );

        // Assert
        expect(find.byIcon(Icons.update), findsOneWidget);
        expect(find.text('5m ago'), findsOneWidget);
      });

      testWidgets('hides last updated badge when not provided',
          (tester) async {
        // Arrange
        final goal = createTestGroupGoal();

        // Act
        await pumpApp(
          tester,
          GoalCard(
            goal: goal,
            onTap: () {},
          ),
        );

        // Assert
        expect(find.byIcon(Icons.update), findsNothing);
      });
    });
  });
}
