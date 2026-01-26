import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading.dart';

// TODO: Import from goals_provider.dart when Epic 5 is completed
// import '../providers/goals_provider.dart';

// TODO: Import from goal.dart entity when Epic 2 is completed
// import '../../domain/entities/goal.dart';

// TODO: Import from goal_progress.dart entity when Epic 2 is completed
// import '../../domain/entities/goal_progress.dart';

// TODO: Import from goal_progress_bar.dart widget when Epic 6 is completed
// import '../widgets/goal_progress_bar.dart';

// TODO: Import from member_ranking_list.dart widget when Epic 6 is completed
// import '../widgets/member_ranking_list.dart';

/// Goal entity for the detail page.
/// TODO: Will be replaced with import from lib/features/goals/domain/entities/goal.dart
class Goal {
  final String id;
  final String name;
  final String? description;
  final int targetSteps;
  final DateTime startDate;
  final DateTime endDate;
  final String creatorId;
  final String creatorUsername;
  final String status;
  final int memberCount;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.name,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.creatorUsername,
    required this.status,
    required this.memberCount,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  double progressPercent(int currentSteps) {
    if (targetSteps <= 0) return 0.0;
    return (currentSteps / targetSteps).clamp(0.0, 1.0);
  }
}

/// GoalProgress entity for member rankings.
/// TODO: Will be replaced with import from lib/features/goals/domain/entities/goal_progress.dart
class GoalProgress {
  final String id;
  final String goalId;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final int todaySteps;
  final int totalSteps;
  final int rank;
  final DateTime lastUpdated;

  const GoalProgress({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.todaySteps,
    required this.totalSteps,
    required this.rank,
    required this.lastUpdated,
  });

  double percentOfTarget(int targetSteps) {
    if (targetSteps <= 0) return 0.0;
    return (todaySteps / targetSteps).clamp(0.0, 1.0);
  }

  String get initials {
    if (username.isEmpty) return '??';
    if (username.length == 1) return username.toUpperCase();
    return username.substring(0, 2).toUpperCase();
  }

  bool get isTopThree => rank <= 3;
}

/// Status enum for goal detail loading state.
enum GoalDetailStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Page displaying detailed information about a specific goal.
///
/// Features:
/// - Goal information (name, description, target, dates)
/// - Overall progress bar
/// - Member rankings list
/// - Invite members action
/// - Pull-to-refresh support
class GoalDetailPage extends StatefulWidget {
  final String goalId;

  const GoalDetailPage({
    super.key,
    required this.goalId,
  });

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  GoalDetailStatus _status = GoalDetailStatus.initial;
  Goal? _goal;
  List<GoalProgress> _memberProgress = [];
  String? _errorMessage;
  String _currentUserId = 'current-user-id'; // TODO: Get from AuthProvider

  @override
  void initState() {
    super.initState();
    _loadGoalDetails();
  }

  Future<void> _loadGoalDetails() async {
    setState(() {
      _status = GoalDetailStatus.loading;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual API call via use case
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulated data - will be replaced with real data from GoalsProvider
      _goal = Goal(
        id: widget.goalId,
        name: 'Loading...',
        description: 'Goal details will load here',
        targetSteps: 10000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        creatorId: 'creator-id',
        creatorUsername: 'Creator',
        status: 'active',
        memberCount: 0,
        createdAt: DateTime.now(),
      );
      _memberProgress = [];

      setState(() {
        _status = GoalDetailStatus.loaded;
      });
    } catch (e) {
      setState(() {
        _status = GoalDetailStatus.error;
        _errorMessage = 'Failed to load goal details. Please try again.';
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadGoalDetails();
  }

  void _navigateToInviteMembers() {
    context.go('/goals/${widget.goalId}/invite');
  }

  void _navigateBack() {
    context.go('/goals');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_goal?.name ?? 'Goal Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: _navigateToInviteMembers,
            tooltip: 'Invite Members',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_status == GoalDetailStatus.loading) {
      return const AppLoading(message: 'Loading goal details...');
    }

    if (_status == GoalDetailStatus.error) {
      return _buildErrorState();
    }

    if (_goal == null) {
      return const AppLoading(message: 'Loading...');
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalInfoCard(),
            const SizedBox(height: AppSpacing.md),
            _buildProgressSection(),
            const SizedBox(height: AppSpacing.md),
            _buildMemberRankingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage ?? 'An error occurred',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _loadGoalDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInfoCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final goal = _goal!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(context, goal),
            ],
          ),
          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              goal.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          _buildGoalStats(goal),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, Goal goal) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    String label;

    if (goal.isActive) {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
      label = 'Active';
    } else if (goal.isCompleted) {
      backgroundColor = colorScheme.tertiaryContainer;
      textColor = colorScheme.onTertiaryContainer;
      label = 'Completed';
    } else {
      backgroundColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
      label = 'Expired';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildGoalStats(Goal goal) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            Icons.directions_walk,
            '${goal.targetSteps}',
            'Daily Target',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            Icons.people_outline,
            '${goal.memberCount}',
            'Members',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            Icons.schedule,
            '${goal.daysRemaining}',
            'Days Left',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 28),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate overall progress (average of all members)
    int totalSteps = 0;
    for (final member in _memberProgress) {
      totalSteps += member.todaySteps;
    }
    final averageSteps =
        _memberProgress.isNotEmpty ? totalSteps ~/ _memberProgress.length : 0;
    final progress = _goal!.progressPercent(averageSteps);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Progress',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _GoalProgressBarWidget(
            progress: progress,
            currentSteps: averageSteps,
            targetSteps: _goal!.targetSteps,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRankingsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Member Rankings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: _navigateToInviteMembers,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Invite'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_memberProgress.isEmpty)
          _buildEmptyMembersState()
        else
          _MemberRankingListWidget(
            members: _memberProgress,
            currentUserId: _currentUserId,
            targetSteps: _goal!.targetSteps,
          ),
      ],
    );
  }

  Widget _buildEmptyMembersState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.group_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No members yet',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Invite friends to join this goal!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _navigateToInviteMembers,
                icon: const Icon(Icons.person_add),
                label: const Text('Invite Members'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Goal progress bar widget displaying progress towards target.
/// TODO: Will be replaced with GoalProgressBar from lib/features/goals/presentation/widgets/goal_progress_bar.dart
class _GoalProgressBarWidget extends StatelessWidget {
  final double progress;
  final int currentSteps;
  final int targetSteps;
  final Color? color;

  const _GoalProgressBarWidget({
    required this.progress,
    required this.currentSteps,
    required this.targetSteps,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currentSteps steps',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 12,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Target: $targetSteps steps/day',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Member ranking list widget displaying ordered member progress.
/// TODO: Will be replaced with MemberRankingList from lib/features/goals/presentation/widgets/member_ranking_list.dart
class _MemberRankingListWidget extends StatelessWidget {
  final List<GoalProgress> members;
  final String currentUserId;
  final int targetSteps;

  const _MemberRankingListWidget({
    required this.members,
    required this.currentUserId,
    required this.targetSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: members.map((member) {
        return _MemberRankingItem(
          member: member,
          isCurrentUser: member.userId == currentUserId,
          targetSteps: targetSteps,
        );
      }).toList(),
    );
  }
}

class _MemberRankingItem extends StatelessWidget {
  final GoalProgress member;
  final bool isCurrentUser;
  final int targetSteps;

  const _MemberRankingItem({
    required this.member,
    required this.isCurrentUser,
    required this.targetSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = member.percentOfTarget(targetSteps);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: isCurrentUser
          ? BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 1,
              ),
            )
          : null,
      child: Row(
        children: [
          _buildRankBadge(context),
          const SizedBox(width: AppSpacing.md),
          AppAvatar(
            imageUrl: member.profileImageUrl,
            initials: member.initials,
            size: AppAvatarSize.small,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.username,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '(You)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${member.todaySteps}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String rankText;
    Color? badgeColor;

    if (member.rank == 1) {
      rankText = '\u{1F947}'; // Gold medal emoji
      badgeColor = const Color(0xFFFFD700);
    } else if (member.rank == 2) {
      rankText = '\u{1F948}'; // Silver medal emoji
      badgeColor = const Color(0xFFC0C0C0);
    } else if (member.rank == 3) {
      rankText = '\u{1F949}'; // Bronze medal emoji
      badgeColor = const Color(0xFFCD7F32);
    } else {
      rankText = '#${member.rank}';
      badgeColor = null;
    }

    if (member.isTopThree) {
      return Text(
        rankText,
        style: const TextStyle(fontSize: 24),
      );
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Text(
        rankText,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
