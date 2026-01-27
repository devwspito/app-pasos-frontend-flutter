/// Goal detail page for displaying a specific goal's information.
///
/// This page shows detailed information about a group goal including
/// progress, members, and actions like invite, leave, and view rankings.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/goal_membership.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/goal_progress.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/member_contribution.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_state.dart';
import 'package:app_pasos_frontend/features/goals/presentation/widgets/goal_progress_indicator.dart';
import 'package:app_pasos_frontend/features/goals/presentation/widgets/member_contribution_tile.dart';
import 'package:app_pasos_frontend/shared/widgets/empty_state.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// TODO(goals): Add routes to RouteNames in router configuration
const String _inviteMembersRoute = '/goals/invite';
const String _goalRankingsRoute = '/goals/rankings';

/// Goal detail page displaying comprehensive information about a goal.
///
/// Features:
/// - Hero section with progress indicator
/// - Goal info section (target, dates, status)
/// - Members list with contribution tiles
/// - Action buttons (invite, leave, rankings)
/// - Pull-to-refresh functionality
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.goalDetail,
///   builder: (context, state) {
///     final goalId = state.uri.queryParameters['goalId'] ?? '';
///     return BlocProvider(
///       create: (context) => GoalDetailBloc(...)
///         ..add(GoalDetailLoadRequested(goalId: goalId)),
///       child: GoalDetailPage(goalId: goalId),
///     );
///   },
/// )
/// ```
class GoalDetailPage extends StatelessWidget {
  /// Creates a [GoalDetailPage].
  ///
  /// [goalId] - The ID of the goal to display.
  const GoalDetailPage({
    required this.goalId,
    super.key,
  });

  /// The ID of the goal to display.
  final String goalId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoalDetailBloc, GoalDetailState>(
      listenWhen: (previous, current) => current is GoalDetailActionSuccess,
      listener: (context, state) {
        if (state is GoalDetailActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          // Reload data after successful action
          context.read<GoalDetailBloc>().add(
                GoalDetailRefreshRequested(goalId: goalId),
              );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<GoalDetailBloc, GoalDetailState>(
            builder: (context, state) {
              if (state is GoalDetailLoaded) {
                return Text(state.goal.name);
              }
              return const Text('Goal Details');
            },
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<GoalDetailBloc, GoalDetailState>(
              builder: (context, state) {
                if (state is GoalDetailLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.leaderboard),
                    onPressed: () => _navigateToRankings(context),
                    tooltip: 'View Rankings',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<GoalDetailBloc, GoalDetailState>(
          builder: (context, state) {
            return switch (state) {
              GoalDetailInitial() => _buildInitialState(context),
              GoalDetailLoading() => const LoadingIndicator(
                  message: 'Loading goal details...',
                ),
              GoalDetailLoaded(
                :final goal,
                :final progress,
                :final members
              ) =>
                _buildLoadedState(context, goal, progress, members),
              GoalDetailError(:final message) => AppErrorWidget(
                  message: message,
                  onRetry: () => _onRefresh(context),
                ),
              GoalDetailActionSuccess() => _buildInitialState(context),
            };
          },
        ),
      ),
    );
  }

  /// Builds the initial state UI.
  Widget _buildInitialState(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalDetailBloc>().add(
            GoalDetailLoadRequested(goalId: goalId),
          );
    });

    return const LoadingIndicator(
      message: 'Initializing...',
    );
  }

  /// Builds the loaded state UI with goal details.
  Widget _buildLoadedState(
    BuildContext context,
    GroupGoal goal,
    GoalProgress progress,
    List<GoalMembership> members,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(context),
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Hero section with progress indicator
          _buildHeroSection(context, goal, progress),
          const SizedBox(height: 24),

          // Goal info section
          _buildInfoSection(context, goal, progress),
          const SizedBox(height: 24),

          // Members section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${members.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () => _navigateToInvite(context, goal),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Invite'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Members list
          if (members.isEmpty)
            const EmptyState(
              icon: Icons.people_outline,
              title: 'No Members',
              message: 'Invite friends to join this goal.',
            )
          else
            _buildMembersList(context, members),
          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(context, goal, colorScheme),
        ],
      ),
    );
  }

  /// Builds the hero section with progress indicator.
  Widget _buildHeroSection(
    BuildContext context,
    GroupGoal goal,
    GoalProgress progress,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GoalProgressIndicator(
            progress: progress.progressPercentage,
            size: 120,
            strokeWidth: 10,
            showPercentage: true,
          ),
          const SizedBox(height: 16),
          Text(
            '${_formatSteps(progress.currentSteps)} / ${_formatSteps(goal.targetSteps)} steps',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${progress.remainingSteps > 0 ? _formatSteps(progress.remainingSteps) : '0'} steps to go',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the goal info section.
  Widget _buildInfoSection(
    BuildContext context,
    GroupGoal goal,
    GoalProgress progress,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Information',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (goal.hasDescription) ...[
            Text(
              goal.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
          ],
          _InfoRow(
            icon: Icons.flag,
            label: 'Target',
            value: '${_formatSteps(goal.targetSteps)} steps',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_today,
            label: 'Period',
            value: '${_formatDate(goal.startDate)} - ${_formatDate(goal.endDate)}',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: _getStatusLabel(goal.status),
            valueColor: _getStatusColor(goal.status, colorScheme),
          ),
        ],
      ),
    );
  }

  /// Builds the members list.
  Widget _buildMembersList(
    BuildContext context,
    List<GoalMembership> members,
  ) {
    return Column(
      children: members.asMap().entries.map((entry) {
        final index = entry.key;
        final member = entry.value;
        // Create a contribution from membership data
        final contribution = MemberContribution(
          id: member.id,
          goalId: member.goalId,
          userId: member.userId,
          userName: 'Member ${member.userId.length > 4 ? member.userId.substring(0, 4) : member.userId}',
          totalSteps: 0, // Would be populated from real data
          contributionPercentage: 0,
          rank: index + 1,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MemberContributionTile(
            contribution: contribution,
          ),
        );
      }).toList(),
    );
  }

  /// Builds the action buttons section.
  Widget _buildActionButtons(
    BuildContext context,
    GroupGoal goal,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _navigateToRankings(context),
          icon: const Icon(Icons.leaderboard),
          label: const Text('View Rankings'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showLeaveDialog(context, goal),
          icon: Icon(Icons.exit_to_app, color: colorScheme.error),
          label: Text(
            'Leave Goal',
            style: TextStyle(color: colorScheme.error),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.error),
          ),
        ),
      ],
    );
  }

  /// Shows a dialog to confirm leaving the goal.
  void _showLeaveDialog(BuildContext context, GroupGoal goal) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Goal'),
        content: Text(
          'Are you sure you want to leave "${goal.name}"? '
          'Your progress will be removed from the group total.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GoalDetailBloc>().add(
                    GoalDetailLeaveRequested(goalId: goal.id),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  /// Navigates to the invite members page.
  void _navigateToInvite(BuildContext context, GroupGoal goal) {
    context.push('$_inviteMembersRoute?goalId=${goal.id}');
  }

  /// Navigates to the goal rankings page.
  void _navigateToRankings(BuildContext context) {
    context.push('$_goalRankingsRoute?goalId=$goalId');
  }

  /// Handles refresh action.
  void _onRefresh(BuildContext context) {
    context.read<GoalDetailBloc>().add(
          GoalDetailRefreshRequested(goalId: goalId),
        );
  }

  /// Formats step count with K/M suffix.
  String _formatSteps(int steps) {
    if (steps >= 1000000) {
      final m = steps / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    }
    if (steps >= 1000) {
      final k = steps / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return steps.toString();
  }

  /// Formats a date for display.
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Returns the display label for the status.
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Returns the color for the status.
  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'completed':
        return colorScheme.tertiary;
      case 'cancelled':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}

/// A row widget displaying an icon, label, and value.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
