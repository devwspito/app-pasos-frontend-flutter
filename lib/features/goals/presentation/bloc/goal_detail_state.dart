/// Goal detail states for the GoalDetailBloc.
///
/// This file defines all possible states that the GoalDetailBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/goal_membership.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/goal_progress.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:equatable/equatable.dart';

/// Base class for all goal detail states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<GoalDetailBloc, GoalDetailState>(
///   builder: (context, state) {
///     return switch (state) {
///       GoalDetailInitial() => const SizedBox.shrink(),
///       GoalDetailLoading() => const LoadingIndicator(),
///       GoalDetailLoaded(:final goal, :final progress, :final members) =>
///         GoalDetailView(goal: goal, progress: progress, members: members),
///       GoalDetailError(:final message) => ErrorWidget(message: message),
///       GoalDetailActionSuccess(:final message) =>
///         SuccessMessage(message: message),
///     };
///   },
/// )
/// ```
sealed class GoalDetailState extends Equatable {
  /// Creates a [GoalDetailState] instance.
  const GoalDetailState();
}

/// Initial state before goal details have been loaded.
///
/// This is the default state when the GoalDetailBloc is first created.
/// The app should transition from this state after loading goal details.
///
/// Example:
/// ```dart
/// if (state is GoalDetailInitial) {
///   // Trigger initial data load
///   context.read<GoalDetailBloc>().add(
///     GoalDetailLoadRequested(goalId: goalId),
///   );
/// }
/// ```
final class GoalDetailInitial extends GoalDetailState {
  /// Creates a [GoalDetailInitial] state.
  const GoalDetailInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that goal details are being loaded.
///
/// This state is emitted when:
/// - Initial detail load is in progress
/// - Pull-to-refresh is in progress
/// - An action is being processed
///
/// Example:
/// ```dart
/// if (state is GoalDetailLoading) {
///   return const CircularProgressIndicator();
/// }
/// ```
final class GoalDetailLoading extends GoalDetailState {
  /// Creates a [GoalDetailLoading] state.
  const GoalDetailLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that goal details have been successfully loaded.
///
/// This state is emitted after successful data fetching and contains
/// all the detailed information about the goal.
///
/// Contains:
/// - [goal] - The goal details
/// - [progress] - The current progress towards the goal
/// - [members] - The list of goal members
///
/// Example:
/// ```dart
/// if (state is GoalDetailLoaded) {
///   return Text('Progress: ${state.progress.progressPercentage}%');
/// }
/// ```
final class GoalDetailLoaded extends GoalDetailState {
  /// Creates a [GoalDetailLoaded] state.
  ///
  /// [goal] - The goal details.
  /// [progress] - The current progress towards the goal.
  /// [members] - The list of goal members.
  const GoalDetailLoaded({
    required this.goal,
    required this.progress,
    required this.members,
  });

  /// The goal details.
  final GroupGoal goal;

  /// The current progress towards the goal.
  final GoalProgress progress;

  /// The list of goal members.
  final List<GoalMembership> members;

  /// Whether the goal has any members.
  bool get hasMembers => members.isNotEmpty;

  /// Total count of members.
  int get memberCount => members.length;

  /// Gets active members only.
  List<GoalMembership> get activeMembers =>
      members.where((m) => m.isActive).toList();

  /// Whether the goal is completed based on progress.
  bool get isCompleted => progress.isCompleted;

  /// The progress as a percentage string.
  String get progressPercentageString =>
      '${progress.progressPercentage.toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [goal, progress, members];
}

/// State indicating that loading goal details has failed.
///
/// This state is emitted when an error occurs during:
/// - Initial detail load
/// - Pull-to-refresh
/// - Invite user action
/// - Leave goal action
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is GoalDetailError) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class GoalDetailError extends GoalDetailState {
  /// Creates a [GoalDetailError] state.
  ///
  /// [message] - A human-readable error message.
  const GoalDetailError({required this.message});

  /// The error message describing what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// State indicating that a goal detail action was successful.
///
/// This state is emitted when:
/// - A user was invited successfully
/// - The user left the goal successfully
///
/// Contains a success [message] to display to the user.
///
/// Example:
/// ```dart
/// BlocListener<GoalDetailBloc, GoalDetailState>(
///   listenWhen: (previous, current) => current is GoalDetailActionSuccess,
///   listener: (context, state) {
///     if (state is GoalDetailActionSuccess) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(state.message)),
///       );
///     }
///   },
/// )
/// ```
final class GoalDetailActionSuccess extends GoalDetailState {
  /// Creates a [GoalDetailActionSuccess] state.
  ///
  /// [message] - A human-readable success message.
  const GoalDetailActionSuccess({required this.message});

  /// The success message describing what action completed.
  final String message;

  @override
  List<Object?> get props => [message];
}
