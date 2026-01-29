/// Edit goal states for the EditGoalBloc.
///
/// This file defines all possible states that the EditGoalBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:equatable/equatable.dart';

/// Base class for all edit goal states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<EditGoalBloc, EditGoalState>(
///   builder: (context, state) {
///     return switch (state) {
///       EditGoalInitial() => const LoadingIndicator(),
///       EditGoalLoading() => const LoadingIndicator(),
///       EditGoalLoaded(:final goal) => EditGoalForm(goal: goal),
///       EditGoalSubmitting() => const LoadingIndicator(),
///       EditGoalSuccess(:final goal) => GoalUpdatedView(goal: goal),
///       EditGoalError(:final message) => ErrorWidget(message: message),
///     };
///   },
/// )
/// ```
sealed class EditGoalState extends Equatable {
  /// Creates an [EditGoalState] instance.
  const EditGoalState();
}

/// Initial state before any goal data has been loaded.
///
/// This is the default state when the EditGoalBloc is first created.
/// The app should show a loading indicator while waiting for data.
///
/// Example:
/// ```dart
/// if (state is EditGoalInitial) {
///   return const LoadingIndicator();
/// }
/// ```
final class EditGoalInitial extends EditGoalState {
  /// Creates an [EditGoalInitial] state.
  const EditGoalInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that goal data is being loaded.
///
/// This state is emitted when fetching existing goal data from the API.
///
/// Example:
/// ```dart
/// if (state is EditGoalLoading) {
///   return const CircularProgressIndicator();
/// }
/// ```
final class EditGoalLoading extends EditGoalState {
  /// Creates an [EditGoalLoading] state.
  const EditGoalLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that goal data was loaded successfully.
///
/// This state is emitted after the goal details have been fetched.
/// The form should be displayed with pre-populated values.
///
/// Contains:
/// - [goal] - The loaded goal data
///
/// Example:
/// ```dart
/// if (state is EditGoalLoaded) {
///   return EditGoalForm(initialGoal: state.goal);
/// }
/// ```
final class EditGoalLoaded extends EditGoalState {
  /// Creates an [EditGoalLoaded] state.
  ///
  /// [goal] - The loaded goal data.
  const EditGoalLoaded({required this.goal});

  /// The loaded goal data.
  final GroupGoal goal;

  @override
  List<Object?> get props => [goal];
}

/// State indicating that a goal update is being submitted.
///
/// This state is emitted when the user submits the edit form
/// and the API call is in progress.
///
/// Example:
/// ```dart
/// if (state is EditGoalSubmitting) {
///   return const CircularProgressIndicator();
/// }
/// ```
final class EditGoalSubmitting extends EditGoalState {
  /// Creates an [EditGoalSubmitting] state.
  ///
  /// [goal] - The current goal data (to preserve form state).
  const EditGoalSubmitting({required this.goal});

  /// The current goal data.
  final GroupGoal goal;

  @override
  List<Object?> get props => [goal];
}

/// State indicating that a goal was updated successfully.
///
/// This state is emitted after the goal has been successfully updated
/// in the backend.
///
/// Contains:
/// - [goal] - The updated goal
///
/// Example:
/// ```dart
/// if (state is EditGoalSuccess) {
///   Navigator.of(context).pop();
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text('Goal "${state.goal.name}" updated!')),
///   );
/// }
/// ```
final class EditGoalSuccess extends EditGoalState {
  /// Creates an [EditGoalSuccess] state.
  ///
  /// [goal] - The updated goal.
  const EditGoalSuccess({required this.goal});

  /// The updated goal.
  final GroupGoal goal;

  @override
  List<Object?> get props => [goal];
}

/// State indicating that an operation has failed.
///
/// This state is emitted when an error occurs during loading or updating.
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is EditGoalError) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class EditGoalError extends EditGoalState {
  /// Creates an [EditGoalError] state.
  ///
  /// [message] - A human-readable error message.
  /// [goal] - Optional goal data to preserve (if loaded before error).
  const EditGoalError({required this.message, this.goal});

  /// The error message describing what went wrong.
  final String message;

  /// The goal data (if available).
  final GroupGoal? goal;

  @override
  List<Object?> get props => [message, goal];
}
