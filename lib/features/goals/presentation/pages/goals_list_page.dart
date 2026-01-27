/// Goals list page for displaying the user's group goals.
///
/// This page shows all group goals the user is participating in,
/// and provides navigation to create new goals and view goal details.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goals_list_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goals_list_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goals_list_state.dart';
import 'package:app_pasos_frontend/features/goals/presentation/widgets/goal_card.dart';
import 'package:app_pasos_frontend/shared/widgets/empty_state.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// TODO(goals): Add routes to RouteNames in router configuration
const String _createGoalRoute = '/goals/create';
const String _goalDetailRoute = '/goals/detail';

/// Goals list page displaying all group goals the user participates in.
///
/// Features:
/// - Pull-to-refresh functionality
/// - List of goal cards with progress data
/// - Empty state when no goals
/// - Navigation to create goal and goal detail pages
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.goals,
///   builder: (context, state) => BlocProvider(
///     create: (context) => GoalsListBloc(...)
///       ..add(const GoalsListLoadRequested()),
///     child: const GoalsListPage(),
///   ),
/// )
/// ```
class GoalsListPage extends StatelessWidget {
  /// Creates a [GoalsListPage].
  const GoalsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(_createGoalRoute),
            tooltip: 'Create Goal',
          ),
        ],
      ),
      body: BlocBuilder<GoalsListBloc, GoalsListState>(
        builder: (context, state) {
          return switch (state) {
            GoalsListInitial() => _buildInitialState(context),
            GoalsListLoading() => const LoadingIndicator(
                message: 'Loading goals...',
              ),
            GoalsListLoaded(:final goals) => _buildLoadedState(context, goals),
            GoalsListError(:final message) => AppErrorWidget(
                message: message,
                onRetry: () => _onRefresh(context),
              ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(_createGoalRoute),
        tooltip: 'Create Goal',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the initial state UI.
  ///
  /// Shows a loading indicator and triggers data load.
  Widget _buildInitialState(BuildContext context) {
    // Trigger initial load when in initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalsListBloc>().add(const GoalsListLoadRequested());
    });

    return const LoadingIndicator(
      message: 'Initializing...',
    );
  }

  /// Builds the loaded state UI with goals list.
  Widget _buildLoadedState(BuildContext context, List<GroupGoal> goals) {
    if (goals.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _onRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: EmptyState(
                icon: Icons.flag_outlined,
                title: 'No Goals Yet',
                message:
                    'Create a group goal to track steps with friends and family.',
                action: FilledButton.icon(
                  onPressed: () => context.push(_createGoalRoute),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Goal'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(context),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: goals.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final goal = goals[index];
          return GoalCard(
            goal: goal,
            onTap: () => _navigateToGoalDetail(context, goal),
          );
        },
      ),
    );
  }

  /// Navigates to the goal detail page.
  void _navigateToGoalDetail(BuildContext context, GroupGoal goal) {
    context.push('$_goalDetailRoute?goalId=${goal.id}');
  }

  /// Handles refresh action by dispatching a refresh event.
  void _onRefresh(BuildContext context) {
    context.read<GoalsListBloc>().add(const GoalsListRefreshRequested());
  }
}
