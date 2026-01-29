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

/// Enum for goal filter options.
enum GoalFilter {
  /// Show all goals.
  all,

  /// Show only active goals.
  active,

  /// Show only completed goals.
  completed,
}

/// Goals list page displaying all group goals the user participates in.
///
/// Features:
/// - Pull-to-refresh functionality
/// - List of goal cards with progress data
/// - Filter chips for All/Active/Completed filtering
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
class GoalsListPage extends StatefulWidget {
  /// Creates a [GoalsListPage].
  const GoalsListPage({super.key});

  @override
  State<GoalsListPage> createState() => _GoalsListPageState();
}

class _GoalsListPageState extends State<GoalsListPage> {
  /// The currently selected filter.
  GoalFilter _selectedFilter = GoalFilter.all;

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
    // Apply local filter to goals
    final filteredGoals = _applyFilter(goals);

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(context),
      child: Column(
        children: [
          // Filter chips
          _buildFilterChips(context),

          // Goals list or empty state
          Expanded(
            child: filteredGoals.isEmpty
                ? _buildEmptyState(context, goals.isEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredGoals.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final goal = filteredGoals[index];
                      return GoalCard(
                        goal: goal,
                        onTap: () => _navigateToGoalDetail(context, goal),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds the filter chips row.
  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: GoalFilter.values.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getFilterLabel(filter)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.onPrimaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                avatar: isSelected
                    ? null
                    : Icon(
                        _getFilterIcon(filter),
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Returns the label for a filter.
  String _getFilterLabel(GoalFilter filter) {
    switch (filter) {
      case GoalFilter.all:
        return 'All';
      case GoalFilter.active:
        return 'Active';
      case GoalFilter.completed:
        return 'Completed';
    }
  }

  /// Returns the icon for a filter.
  IconData _getFilterIcon(GoalFilter filter) {
    switch (filter) {
      case GoalFilter.all:
        return Icons.list;
      case GoalFilter.active:
        return Icons.play_circle_outline;
      case GoalFilter.completed:
        return Icons.check_circle_outline;
    }
  }

  /// Applies the selected filter to the goals list.
  List<GroupGoal> _applyFilter(List<GroupGoal> goals) {
    switch (_selectedFilter) {
      case GoalFilter.all:
        return goals;
      case GoalFilter.active:
        return goals
            .where((goal) => goal.status.toLowerCase() == 'active')
            .toList();
      case GoalFilter.completed:
        return goals
            .where((goal) => goal.status.toLowerCase() == 'completed')
            .toList();
    }
  }

  /// Builds the empty state widget.
  Widget _buildEmptyState(BuildContext context, bool noGoalsExist) {
    // If no goals exist at all, show create goal prompt
    if (noGoalsExist) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
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
      );
    }

    // If goals exist but none match the filter
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: EmptyState(
            icon: _selectedFilter == GoalFilter.active
                ? Icons.play_circle_outline
                : Icons.check_circle_outline,
            title: _selectedFilter == GoalFilter.active
                ? 'No Active Goals'
                : 'No Completed Goals',
            message: _selectedFilter == GoalFilter.active
                ? 'All your goals are completed or cancelled.'
                : 'You haven\'t completed any goals yet. Keep walking!',
          ),
        ),
      ],
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
