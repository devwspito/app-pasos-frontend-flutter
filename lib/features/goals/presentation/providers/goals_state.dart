import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_progress.dart';

/// Represents the possible goals data loading statuses.
enum GoalsStatus {
  /// Initial state before any data fetch.
  initial,

  /// Currently loading goal data.
  loading,

  /// Goal data loaded successfully.
  loaded,

  /// Error occurred while loading goal data.
  error,
}

/// Immutable state class for goals feature data.
///
/// Uses [Equatable] for value-based equality comparison.
/// State transitions should use [copyWith] to maintain immutability.
///
/// Example:
/// ```dart
/// final state = GoalsState.initial();
/// final loadingState = state.copyWith(status: GoalsStatus.loading, isLoading: true);
/// final loadedState = loadingState.copyWith(
///   status: GoalsStatus.loaded,
///   goals: goalsList,
///   isLoading: false,
/// );
/// ```
@immutable
final class GoalsState extends Equatable {
  const GoalsState({
    this.status = GoalsStatus.initial,
    this.isLoading = false,
    this.goals = const [],
    this.selectedGoal,
    this.goalProgress,
    this.errorMessage,
    this.lastUpdated,
  });

  /// Current data loading status.
  final GoalsStatus status;

  /// Whether an async operation is in progress.
  final bool isLoading;

  /// List of user's goals (both individual and group).
  final List<Goal> goals;

  /// Currently selected goal for detailed view.
  final Goal? selectedGoal;

  /// Progress data for the selected goal.
  final GoalProgress? goalProgress;

  /// Error message from the last failed operation.
  final String? errorMessage;

  /// Timestamp of the last successful data update.
  final DateTime? lastUpdated;

  /// Factory constructor for initial state.
  const GoalsState.initial()
      : status = GoalsStatus.initial,
        isLoading = false,
        goals = const [],
        selectedGoal = null,
        goalProgress = null,
        errorMessage = null,
        lastUpdated = null;

  /// Factory constructor for loading state.
  const GoalsState.loading()
      : status = GoalsStatus.loading,
        isLoading = true,
        goals = const [],
        selectedGoal = null,
        goalProgress = null,
        errorMessage = null,
        lastUpdated = null;

  /// Creates a copy with optional field overrides.
  ///
  /// This is the only way to create new state from existing state.
  /// Direct mutation is not allowed.
  ///
  /// Use [clearError] to explicitly set errorMessage to null.
  /// Use [clearGoals] to explicitly set goals to empty list.
  /// Use [clearSelectedGoal] to explicitly set selectedGoal to null.
  /// Use [clearProgress] to explicitly set goalProgress to null.
  GoalsState copyWith({
    GoalsStatus? status,
    bool? isLoading,
    List<Goal>? goals,
    Goal? selectedGoal,
    GoalProgress? goalProgress,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearError = false,
    bool clearGoals = false,
    bool clearSelectedGoal = false,
    bool clearProgress = false,
  }) {
    return GoalsState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      goals: clearGoals ? const [] : (goals ?? this.goals),
      selectedGoal: clearSelectedGoal ? null : (selectedGoal ?? this.selectedGoal),
      goalProgress: clearProgress ? null : (goalProgress ?? this.goalProgress),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Returns true if data has been loaded at least once.
  bool get hasData => goals.isNotEmpty || selectedGoal != null;

  /// Returns true if there's an error.
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Returns true if initial loading is in progress.
  bool get isInitialLoading => status == GoalsStatus.loading && !hasData;

  /// Returns true if refreshing existing data.
  bool get isRefreshing => isLoading && hasData;

  /// Returns the number of active goals.
  int get activeGoalsCount => goals.where((g) => g.isActive).length;

  /// Returns the number of group goals.
  int get groupGoalsCount => goals.where((g) => g.isGroup).length;

  /// Returns the number of individual goals.
  int get individualGoalsCount => goals.where((g) => !g.isGroup).length;

  /// Returns active individual goals.
  List<Goal> get activeIndividualGoals =>
      goals.where((g) => g.isActive && !g.isGroup).toList();

  /// Returns active group goals.
  List<Goal> get activeGroupGoals =>
      goals.where((g) => g.isActive && g.isGroup).toList();

  /// Returns completed goals.
  List<Goal> get completedGoals =>
      goals.where((g) => g.status == GoalStatus.completed).toList();

  @override
  List<Object?> get props => [
        status,
        isLoading,
        goals,
        selectedGoal,
        goalProgress,
        errorMessage,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'GoalsState('
        'status: $status, '
        'isLoading: $isLoading, '
        'goals: ${goals.length}, '
        'selectedGoal: ${selectedGoal?.name}, '
        'error: $errorMessage'
        ')';
  }
}
