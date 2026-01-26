import 'package:flutter/material.dart';

/// Domain entity representing a member's progress toward a group goal.
///
/// Contains step count and user information for ranking display.
class GoalProgress {
  /// Unique identifier for the member.
  final String memberId;

  /// Username of the member.
  final String username;

  /// Profile avatar URL. May be null if not set.
  final String? avatarUrl;

  /// Total steps contributed by this member toward the goal.
  final int totalSteps;

  /// Creates a [GoalProgress] instance.
  const GoalProgress({
    required this.memberId,
    required this.username,
    this.avatarUrl,
    required this.totalSteps,
  });

  /// Returns the first 2 letters of the username as initials.
  ///
  /// Returns uppercase initials. If the username is empty, returns an empty string.
  String get initials {
    if (username.isEmpty) return '';
    if (username.length == 1) return username.toUpperCase();
    return username.substring(0, 2).toUpperCase();
  }
}

/// A widget that displays a ranked list of members sorted by step contribution.
///
/// Shows member avatar, username, steps, and progress percentage.
/// Members are sorted by totalSteps in descending order.
/// Top 3 members receive special rank badges (gold, silver, bronze).
///
/// Example:
/// ```dart
/// MemberRankingList(
///   members: memberProgressList,
///   targetSteps: 100000,
/// )
/// ```
class MemberRankingList extends StatelessWidget {
  /// Creates a [MemberRankingList] widget.
  ///
  /// [members] is the list of member progress data.
  /// [targetSteps] is the total target steps for the goal (used for progress calculation).
  const MemberRankingList({
    super.key,
    required this.members,
    required this.targetSteps,
  });

  /// List of members with their progress data.
  final List<GoalProgress> members;

  /// Total target steps for the goal.
  final int targetSteps;

  /// Returns a sorted copy of members by totalSteps descending.
  List<GoalProgress> get _sortedMembers {
    final sorted = List<GoalProgress>.from(members);
    sorted.sort((a, b) => b.totalSteps.compareTo(a.totalSteps));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sortedMembers = _sortedMembers;

    if (sortedMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No members yet',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedMembers.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final member = sortedMembers[index];
        final rank = index + 1;
        return _MemberRankingTile(
          member: member,
          rank: rank,
          targetSteps: targetSteps,
        );
      },
    );
  }
}

/// A single tile displaying a member's ranking information.
class _MemberRankingTile extends StatelessWidget {
  const _MemberRankingTile({
    required this.member,
    required this.rank,
    required this.targetSteps,
  });

  final GoalProgress member;
  final int rank;
  final int targetSteps;

  /// Calculates the member's progress percentage.
  double get _progress {
    if (targetSteps <= 0) return 0.0;
    return (member.totalSteps / targetSteps).clamp(0.0, 1.0);
  }

  /// Returns the progress as a percentage integer.
  int get _progressPercentage => (_progress * 100).round();

  /// Returns the rank badge widget for top 3 positions.
  Widget? _buildRankBadge(ColorScheme colorScheme) {
    switch (rank) {
      case 1:
        return _RankBadge(
          icon: Icons.emoji_events,
          color: const Color(0xFFFFD700), // Gold
          rank: rank,
        );
      case 2:
        return _RankBadge(
          icon: Icons.emoji_events,
          color: const Color(0xFFC0C0C0), // Silver
          rank: rank,
        );
      case 3:
        return _RankBadge(
          icon: Icons.emoji_events,
          color: const Color(0xFFCD7F32), // Bronze
          rank: rank,
        );
      default:
        return _RankNumber(rank: rank, colorScheme: colorScheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Rank badge or number
          SizedBox(
            width: 40,
            child: _buildRankBadge(colorScheme),
          ),

          const SizedBox(width: 12),

          // Avatar
          _MemberAvatar(
            avatarUrl: member.avatarUrl,
            initials: member.initials,
            colorScheme: colorScheme,
          ),

          const SizedBox(width: 12),

          // Username and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.username,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 4,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(colorScheme),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_progressPercentage%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Steps count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(member.totalSteps),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'steps',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns progress color based on percentage.
  Color _getProgressColor(ColorScheme colorScheme) {
    if (_progress < 0.5) {
      return colorScheme.error;
    } else if (_progress < 0.8) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  /// Formats a number with thousands separators.
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

/// A circular avatar widget for members.
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.avatarUrl,
    required this.initials,
    required this.colorScheme,
  });

  final String? avatarUrl;
  final String initials;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: colorScheme.surfaceContainerHighest,
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// A badge widget for top 3 ranks with trophy icon.
class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.icon,
    required this.color,
    required this.rank,
  });

  final IconData icon;
  final Color color;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          icon,
          size: 28,
          color: color,
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A simple rank number display for ranks > 3.
class _RankNumber extends StatelessWidget {
  const _RankNumber({
    required this.rank,
    required this.colorScheme,
  });

  final int rank;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerHighest,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
