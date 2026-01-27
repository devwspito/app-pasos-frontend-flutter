/// Goal rankings page for displaying member leaderboard.
///
/// This page shows a ranked list of all goal members sorted by
/// their step contributions to the group goal.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/goal_membership.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/member_contribution.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_state.dart';
import 'package:app_pasos_frontend/features/goals/presentation/widgets/ranking_list_item.dart';
import 'package:app_pasos_frontend/shared/widgets/empty_state.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Goal rankings page displaying the member leaderboard.
///
/// Features:
/// - Pull-to-refresh functionality
/// - List of members sorted by contribution
/// - Trophy icons for top 3 contributors
/// - Empty state when no members
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.goalRankings,
///   builder: (context, state) {
///     final goalId = state.uri.queryParameters['goalId'] ?? '';
///     return BlocProvider(
///       create: (context) => GoalDetailBloc(...)
///         ..add(GoalDetailLoadRequested(goalId: goalId)),
///       child: GoalRankingsPage(goalId: goalId),
///     );
///   },
/// )
/// ```
class GoalRankingsPage extends StatelessWidget {
  /// Creates a [GoalRankingsPage].
  ///
  /// [goalId] - The ID of the goal to show rankings for.
  const GoalRankingsPage({
    required this.goalId,
    super.key,
  });

  /// The ID of the goal to show rankings for.
  final String goalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
        centerTitle: true,
      ),
      body: BlocBuilder<GoalDetailBloc, GoalDetailState>(
        builder: (context, state) {
          return switch (state) {
            GoalDetailInitial() => _buildInitialState(context),
            GoalDetailLoading() => const LoadingIndicator(
                message: 'Loading rankings...',
              ),
            GoalDetailLoaded(:final goal, :final members) =>
              _buildLoadedState(context, goal.name, members),
            GoalDetailError(:final message) => AppErrorWidget(
                message: message,
                onRetry: () => _onRefresh(context),
              ),
            GoalDetailActionSuccess() => _buildInitialState(context),
          };
        },
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

  /// Builds the loaded state UI with rankings list.
  Widget _buildLoadedState(
    BuildContext context,
    String goalName,
    List<GoalMembership> members,
  ) {
    final theme = Theme.of(context);

    // Create sample contributions from members for display
    // In production, this would come from the API with real contribution data
    final contributions = members.asMap().entries.map((entry) {
      final idx = entry.key;
      final member = entry.value;
      final userId = member.userId;
      return MemberContribution(
        id: member.id,
        goalId: member.goalId,
        userId: userId,
        userName: 'Member ${userId.length > 4 ? userId.substring(0, 4) : userId}',
        totalSteps: (members.length - idx) * 5000, // Sample data
        contributionPercentage: ((members.length - idx) / members.length) * 100,
        rank: idx + 1,
      );
    }).toList();

    if (contributions.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _onRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const EmptyState(
                icon: Icons.leaderboard_outlined,
                title: 'No Rankings Yet',
                message:
                    'Start walking to see your ranking among goal members.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(context),
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Header section
          _buildHeader(context, goalName, contributions.length),
          const SizedBox(height: 16),

          // Podium for top 3 (if at least 3 members)
          if (contributions.length >= 3) ...[
            _buildPodium(context, contributions.take(3).toList()),
            const SizedBox(height: 24),
          ],

          // Full rankings list
          Text(
            'All Members',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Rankings list
          ...contributions.map(
            (contribution) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RankingListItem(
                contribution: contribution,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the header section with goal name and member count.
  Widget _buildHeader(
    BuildContext context,
    String goalName,
    int memberCount,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            size: 32,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goalName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$memberCount members competing',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the podium section for top 3 contributors.
  Widget _buildPodium(
    BuildContext context,
    List<MemberContribution> topThree,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Reorder for podium display: 2nd, 1st, 3rd
    final podiumOrder = [
      if (topThree.length > 1) topThree[1], // 2nd place (left)
      topThree[0], // 1st place (center, taller)
      if (topThree.length > 2) topThree[2], // 3rd place (right)
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: podiumOrder.asMap().entries.map((entry) {
          final contribution = entry.value;
          final isFirst = contribution.rank == 1;

          return _PodiumPlace(
            contribution: contribution,
            height: isFirst ? 100 : 80,
            isFirst: isFirst,
          );
        }).toList(),
      ),
    );
  }

  /// Handles refresh action.
  void _onRefresh(BuildContext context) {
    context.read<GoalDetailBloc>().add(
          GoalDetailRefreshRequested(goalId: goalId),
        );
  }
}

/// A podium place widget showing a single member's position.
class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.contribution,
    required this.height,
    required this.isFirst,
  });

  final MemberContribution contribution;
  final double height;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rankColor = _getRankColor(contribution.rank);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal emoji
        Text(
          _getRankEmoji(contribution.rank),
          style: TextStyle(fontSize: isFirst ? 32 : 24),
        ),
        const SizedBox(height: 4),

        // Name
        SizedBox(
          width: 80,
          child: Text(
            contribution.userName,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),

        // Steps
        Text(
          _formatSteps(contribution.totalSteps),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        // Podium block
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: rankColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '${contribution.rank}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Returns the color for the rank.
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  /// Returns the emoji for the rank.
  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🏅';
    }
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
}
