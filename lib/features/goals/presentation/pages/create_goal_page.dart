/// Create goal page for creating new group goals.
///
/// This page provides a form for users to create new group goals
/// with name, description, target steps, and date range.
library;

import 'package:app_pasos_frontend/features/goals/presentation/bloc/create_goal_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/create_goal_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/create_goal_state.dart';
import 'package:app_pasos_frontend/features/goals/presentation/widgets/goal_form.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Create goal page for creating new group goals.
///
/// Features:
/// - Goal form with validation
/// - Loading state during submission
/// - Success/error feedback with snackbars
/// - Navigation back on success
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.createGoal,
///   builder: (context, state) => BlocProvider(
///     create: (context) => CreateGoalBloc(...),
///     child: const CreateGoalPage(),
///   ),
/// )
/// ```
class CreateGoalPage extends StatelessWidget {
  /// Creates a [CreateGoalPage].
  const CreateGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<CreateGoalBloc, CreateGoalState>(
      listener: (context, state) {
        if (state is CreateGoalSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Goal "${state.goal.name}" created successfully!'),
              backgroundColor: colorScheme.primary,
            ),
          );
          // Navigate back to goals list
          context.pop();
        } else if (state is CreateGoalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
          // Reset the bloc to allow retry
          context.read<CreateGoalBloc>().add(const CreateGoalReset());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Goal'),
          centerTitle: true,
        ),
        body: BlocBuilder<CreateGoalBloc, CreateGoalState>(
          builder: (context, state) {
            return switch (state) {
              CreateGoalInitial() => _buildForm(context, isLoading: false),
              CreateGoalSubmitting() => _buildForm(context, isLoading: true),
              CreateGoalSuccess() => const LoadingIndicator(
                  message: 'Goal created!',
                ),
              CreateGoalError() => _buildForm(context, isLoading: false),
            };
          },
        ),
      ),
    );
  }

  /// Builds the goal creation form.
  Widget _buildForm(BuildContext context, {required bool isLoading}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GoalForm(
        isLoading: isLoading,
        onSubmit: (name, description, targetSteps, startDate, endDate) {
          context.read<CreateGoalBloc>().add(
                CreateGoalSubmitted(
                  name: name,
                  description: description,
                  targetSteps: targetSteps,
                  startDate: startDate,
                  endDate: endDate,
                ),
              );
        },
      ),
    );
  }
}
