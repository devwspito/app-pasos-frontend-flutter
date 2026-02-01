/// Widget test helpers for App Pasos application.
///
/// This file provides reusable test utilities including:
/// - [pumpApp] for wrapping widgets with MaterialApp and theme
/// - [createMockBloc] for creating mock BLoC instances
/// - [createTestGroupGoal] for generating test GroupGoal data
/// - [createTestGoalProgress] for generating test GoalProgress data
library;

import 'package:app_pasos_frontend/core/theme/app_theme.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/goal_progress.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a widget wrapped with MaterialApp and the app's light theme.
///
/// This helper ensures widgets are tested in an environment that matches
/// the production app configuration, including proper theme setup.
///
/// Example usage:
/// ```dart
/// testWidgets('MyWidget renders correctly', (tester) async {
///   await pumpApp(tester, const MyWidget());
///   expect(find.text('Hello'), findsOneWidget);
/// });
/// ```
///
/// [tester] - The WidgetTester instance from the test.
/// [child] - The widget to test.
/// [theme] - Optional ThemeData to use instead of the default light theme.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps a widget wrapped with MaterialApp, theme, and BLoC providers.
///
/// Use this when testing widgets that depend on BLoC state management.
///
/// Example usage:
/// ```dart
/// testWidgets('Widget with BLoC renders', (tester) async {
///   final mockBloc = MockMyBloc();
///   await pumpAppWithBloc<MyBloc, MyState>(
///     tester,
///     const MyWidget(),
///     bloc: mockBloc,
///   );
///   expect(find.text('State value'), findsOneWidget);
/// });
/// ```
///
/// [tester] - The WidgetTester instance from the test.
/// [child] - The widget to test.
/// [bloc] - The BLoC instance to provide.
/// [theme] - Optional ThemeData to use instead of the default light theme.
Future<void> pumpAppWithBloc<B extends StateStreamableSource<S>, S>(
  WidgetTester tester,
  Widget child, {
  required B bloc,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: BlocProvider<B>.value(
        value: bloc,
        child: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A simple mock BLoC for testing purposes.
///
/// This class provides a basic implementation of a BLoC that can be used
/// in tests without requiring additional mocking dependencies.
///
/// Example usage:
/// ```dart
/// final mockBloc = MockBloc<MyEvent, MyState>(
///   initialState: MyState.initial(),
/// );
/// mockBloc.emitState(MyState.loaded(data));
/// ```
class MockBloc<E, S> extends Bloc<E, S> {
  /// Creates a mock BLoC with the given initial state.
  MockBloc({required S initialState}) : super(initialState) {
    on<E>((event, emit) {
      // Default: do nothing, states are emitted via emitState
    });
  }

  /// Emits a new state to the BLoC's stream.
  ///
  /// Use this to simulate state changes in tests.
  void emitState(S newState) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(newState);
  }
}

/// Creates a mock BLoC instance with the specified initial state.
///
/// This is a convenience function for creating [MockBloc] instances.
///
/// Example usage:
/// ```dart
/// final bloc = createMockBloc<MyEvent, MyState>(MyState.initial());
/// ```
///
/// [initialState] - The initial state for the mock BLoC.
MockBloc<E, S> createMockBloc<E, S>({required S initialState}) {
  return MockBloc<E, S>(initialState: initialState);
}

/// Creates a test [GroupGoal] instance with sensible defaults.
///
/// All parameters are optional and have default test values.
/// Override any parameter to customize the test data.
///
/// Example usage:
/// ```dart
/// final goal = createTestGroupGoal(name: 'Custom Goal');
/// expect(goal.name, 'Custom Goal');
/// ```
GroupGoal createTestGroupGoal({
  String id = 'test-goal-id',
  String name = 'Test Goal',
  String? description = 'A test goal description',
  int targetSteps = 10000,
  DateTime? startDate,
  DateTime? endDate,
  String creatorId = 'test-creator-id',
  String status = 'active',
  DateTime? createdAt,
}) {
  final now = DateTime.now();
  return GroupGoal(
    id: id,
    name: name,
    description: description,
    targetSteps: targetSteps,
    startDate: startDate ?? now,
    endDate: endDate ?? now.add(const Duration(days: 30)),
    creatorId: creatorId,
    status: status,
    createdAt: createdAt ?? now,
  );
}

/// Creates a test [GoalProgress] instance with sensible defaults.
///
/// All parameters are optional and have default test values.
/// Override any parameter to customize the test data.
///
/// Example usage:
/// ```dart
/// final progress = createTestGoalProgress(currentSteps: 5000);
/// expect(progress.progressPercentage, 50.0);
/// ```
GoalProgress createTestGoalProgress({
  String id = 'test-progress-id',
  String goalId = 'test-goal-id',
  int currentSteps = 5000,
  int targetSteps = 10000,
  double? progressPercentage,
  DateTime? lastUpdated,
}) {
  final calculatedPercentage = progressPercentage ??
      (targetSteps > 0 ? (currentSteps / targetSteps) * 100 : 0.0);

  return GoalProgress(
    id: id,
    goalId: goalId,
    currentSteps: currentSteps,
    targetSteps: targetSteps,
    progressPercentage: calculatedPercentage,
    lastUpdated: lastUpdated ?? DateTime.now(),
  );
}
