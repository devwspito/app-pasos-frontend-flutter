/// Create goal states for the CreateGoalBloc.
///
/// This file defines all possible states that the CreateGoalBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:equatable/equatable.dart';

/// Base class for all create goal states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<CreateGoalBloc, CreateGoalState>(
///   builder: (context, state) {
///     return switch (state) {
///       CreateGoalInitial() => const CreateGoalForm(),
///       CreateGoalSubmitting() => const LoadingIndicator(),
///       CreateGoalSuccess(:final goal) => GoalCreatedView(goal: goal),
///       CreateGoalError(:final message) => ErrorWidget(message: message),
///     };
///   },
/// )
/// ```
sealed class CreateGoalState extends Equatable {
  /// Creates a [CreateGoalState] instance.
  const CreateGoalState();
}

/// Initial state before any goal creation has been attempted.
///
/// This is the default state when the CreateGoalBloc is first created.
/// The app should show the goal creation form in this state.
///
/// Example:
/// ```dart
/// if (state is CreateGoalInitial) {
///   return const CreateGoalForm();
/// }
/// ```
final class CreateGoalInitial extends CreateGoalState {
  /// Creates a [CreateGoalInitial] state.
  const CreateGoalInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that a goal is being created.
///
/// This state is emitted when the user submits the goal creation form
/// and the API call is in progress.
///
/// Example:
/// ```dart
/// if (state is CreateGoalSubmitting) {
///   return const CircularProgressIndicator();
/// }
/// ```
final class CreateGoalSubmitting extends CreateGoalState {
  /// Creates a [CreateGoalSubmitting] state.
  const CreateGoalSubmitting();

  @override
  List<Object?> get props => [];
}

/// State indicating that a goal was created successfully.
///
/// This state is emitted after the goal has been successfully created
/// in the backend.
///
/// Contains:
/// - [goal] - The newly created goal
///
/// Example:
/// ```dart
/// if (state is CreateGoalSuccess) {
///   Navigator.of(context).pop();
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text('Goal "${state.goal.name}" created!')),
///   );
/// }
/// ```
final class CreateGoalSuccess extends CreateGoalState {
  /// Creates a [CreateGoalSuccess] state.
  ///
  /// [goal] - The newly created goal.
  const CreateGoalSuccess({required this.goal});

  /// The newly created goal.
  final GroupGoal goal;

  @override
  List<Object?> get props => [goal];
}

/// State indicating that goal creation has failed.
///
/// This state is emitted when an error occurs during goal creation.
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is CreateGoalError) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class CreateGoalError extends CreateGoalState {
  /// Creates a [CreateGoalError] state.
  ///
  /// [message] - A human-readable error message.
  const CreateGoalError({required this.message});

  /// The error message describing what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];
}
