/// Goals list states for the GoalsListBloc.
///
/// This file defines all possible states that the GoalsListBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:equatable/equatable.dart';

/// Base class for all goals list states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<GoalsListBloc, GoalsListState>(
///   builder: (context, state) {
///     return switch (state) {
///       GoalsListInitial() => const SizedBox.shrink(),
///       GoalsListLoading() => const LoadingIndicator(),
///       GoalsListLoaded(:final goals) => GoalsList(goals: goals),
///       GoalsListError(:final message) => ErrorWidget(message: message),
///     };
///   },
/// )
/// ```
sealed class GoalsListState extends Equatable {
  /// Creates a [GoalsListState] instance.
  const GoalsListState();
}

/// Initial state before any goals have been loaded.
///
/// This is the default state when the GoalsListBloc is first created.
/// The app should transition from this state after loading goals data.
///
/// Example:
/// ```dart
/// if (state is GoalsListInitial) {
///   // Trigger initial data load
///   context.read<GoalsListBloc>().add(const GoalsListLoadRequested());
/// }
/// ```
final class GoalsListInitial extends GoalsListState {
  /// Creates a [GoalsListInitial] state.
  const GoalsListInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that goals data is being loaded.
///
/// This state is emitted when:
/// - Initial data load is in progress
/// - Pull-to-refresh is in progress
///
/// Example:
/// ```dart
/// if (state is GoalsListLoading) {
///   return const CircularProgressIndicator();
/// }
/// ```
final class GoalsListLoading extends GoalsListState {
  /// Creates a [GoalsListLoading] state.
  const GoalsListLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that goals have been successfully loaded.
///
/// This state is emitted after successful data fetching and contains
/// all the group goals for the current user.
///
/// Contains:
/// - [goals] - All group goals (created and joined)
///
/// Example:
/// ```dart
/// if (state is GoalsListLoaded) {
///   final goalCount = state.goals.length;
///   return Text('You have $goalCount goals');
/// }
/// ```
final class GoalsListLoaded extends GoalsListState {
  /// Creates a [GoalsListLoaded] state.
  ///
  /// [goals] - All group goals for the current user.
  const GoalsListLoaded({
    required this.goals,
  });

  /// All group goals for the current user.
  ///
  /// Includes both goals the user created and goals they joined.
  final List<GroupGoal> goals;

  /// Whether the user has any goals.
  bool get hasGoals => goals.isNotEmpty;

  /// Total count of all goals.
  int get goalCount => goals.length;

  /// Gets active goals only.
  List<GroupGoal> get activeGoals => goals.where((g) => g.isActive).toList();

  /// Gets completed goals only.
  List<GroupGoal> get completedGoals =>
      goals.where((g) => g.isCompleted).toList();

  @override
  List<Object?> get props => [goals];
}

/// State indicating that loading goals has failed.
///
/// This state is emitted when an error occurs during:
/// - Initial data load
/// - Pull-to-refresh
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is GoalsListError) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class GoalsListError extends GoalsListState {
  /// Creates a [GoalsListError] state.
  ///
  /// [message] - A human-readable error message.
  const GoalsListError({required this.message});

  /// The error message describing what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];
}
