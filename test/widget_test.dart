// Widget tests for App Pasos application.
//
// These tests verify that the application widgets render correctly
// and function as expected.

import 'package:app_pasos_frontend/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/widget_test_helpers.dart';

void main() {
  group('App Widget Tests', () {
    // Skip: App requires GetIt dependency injection setup.
    // TODO(epic-di): Set up test-specific GetIt registrations for App tests.
    testWidgets(
      'App renders Foundation Ready screen - requires DI setup',
      (WidgetTester tester) async {
        // Build our app and trigger a frame.
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        // Verify that the app title is displayed.
        expect(find.text('App Pasos'), findsWidgets);

        // Verify that the foundation ready message is displayed.
        expect(find.text('Foundation Ready'), findsOneWidget);
      },
      skip: true,
    );
  });

  group('Widget Test Helpers', () {
    testWidgets('pumpApp wraps widget with MaterialApp and theme', (
      WidgetTester tester,
    ) async {
      // Create a simple widget that displays theme-dependent text
      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Text(
              'Theme loaded',
              style: TextStyle(color: theme.colorScheme.primary),
            );
          },
        ),
      );

      // Verify the widget was rendered
      expect(find.text('Theme loaded'), findsOneWidget);
    });

    test('createTestGroupGoal creates valid GroupGoal', () {
      final goal = createTestGroupGoal(
        id: 'custom-id',
        name: 'Custom Goal Name',
        targetSteps: 20000,
      );

      expect(goal.id, 'custom-id');
      expect(goal.name, 'Custom Goal Name');
      expect(goal.targetSteps, 20000);
      expect(goal.status, 'active');
      expect(goal.isActive, isTrue);
    });

    test('createTestGroupGoal uses default values', () {
      final goal = createTestGroupGoal();

      expect(goal.id, 'test-goal-id');
      expect(goal.name, 'Test Goal');
      expect(goal.targetSteps, 10000);
      expect(goal.description, 'A test goal description');
      expect(goal.creatorId, 'test-creator-id');
      expect(goal.status, 'active');
    });

    test('createTestGoalProgress creates valid GoalProgress', () {
      final progress = createTestGoalProgress(
        id: 'custom-progress-id',
        currentSteps: 7500,
        targetSteps: 15000,
      );

      expect(progress.id, 'custom-progress-id');
      expect(progress.currentSteps, 7500);
      expect(progress.targetSteps, 15000);
      expect(progress.progressPercentage, 50.0);
    });

    test('createTestGoalProgress uses default values', () {
      final progress = createTestGoalProgress();

      expect(progress.id, 'test-progress-id');
      expect(progress.goalId, 'test-goal-id');
      expect(progress.currentSteps, 5000);
      expect(progress.targetSteps, 10000);
      expect(progress.progressPercentage, 50.0);
    });

    test('createMockBloc creates functional mock', () {
      final mockBloc = createMockBloc<String, int>(initialState: 0);

      expect(mockBloc.state, 0);

      mockBloc.emitState(42);
      expect(mockBloc.state, 42);

      mockBloc.close();
    });
  });
}
