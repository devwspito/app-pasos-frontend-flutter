/// Ranking list item widget for displaying leaderboard entries.
///
/// This widget shows a member's rank position with avatar, name,
/// steps, and medal icons for the top 3 contributors.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/member_contribution.dart';
import 'package:app_pasos_frontend/shared/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

/// A list item widget that displays a member's rank in the leaderboard.
///
/// Shows the member's rank number (with trophy icons for top 3),
/// avatar, name, and step count. Supports tap interaction.
///
/// Example usage:
/// ```dart
/// RankingListItem(
///   contribution: memberContribution,
///   onTap: () => navigateToMemberProfile(),
/// )
/// ```
class RankingListItem extends StatelessWidget {
  /// Creates a [RankingListItem].
  ///
  /// The [contribution] parameter is required.
  const RankingListItem({
    required this.contribution,
    this.onTap,
    this.avatarUrl,
    super.key,
  });

  /// The member contribution data to display.
  final MemberContribution contribution;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional URL for the member's avatar image.
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isTopThree = contribution.isTopThree;
    final backgroundColor = isTopThree
        ? _getRankBackgroundColor(contribution.rank, colorScheme)
        : Colors.transparent;

    final content = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          // Rank indicator
          SizedBox(
            width: 40,
            child: _RankIndicator(rank: contribution.rank),
          ),
          const SizedBox(width: 12),

          // Avatar
          AvatarWidget(
            imageUrl: avatarUrl,
            name: contribution.userName,
            size: 44,
            borderColor:
                isTopThree ? _getRankBorderColor(contribution.rank) : null,
            borderWidth: isTopThree ? 2 : null,
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contribution.userName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: isTopThree ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${contribution.contributionPercentage.toStringAsFixed(1)}'
                  '% of total',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Steps badge
          _StepsBadge(steps: contribution.totalSteps),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return content;
  }

  /// Returns the background color for top 3 ranks.
  Color _getRankBackgroundColor(int rank, ColorScheme colorScheme) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700).withOpacity(0.15); // Gold
      case 2:
        return const Color(0xFFC0C0C0).withOpacity(0.15); // Silver
      case 3:
        return const Color(0xFFCD7F32).withOpacity(0.15); // Bronze
      default:
        return Colors.transparent;
    }
  }

  /// Returns the border color for top 3 ranks.
  Color _getRankBorderColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.transparent;
    }
  }
}

/// Rank indicator showing position number or trophy icon.
class _RankIndicator extends StatelessWidget {
  const _RankIndicator({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Trophy icons for top 3
    if (rank >= 1 && rank <= 3) {
      return _TrophyIcon(rank: rank);
    }

    // Number for other ranks
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rank.toString(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Trophy icon for top 3 ranks.
class _TrophyIcon extends StatelessWidget {
  const _TrophyIcon({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final (emoji, label) = _getTrophyInfo();

    return Semantics(
      label: label,
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Returns the trophy emoji and accessibility label for the rank.
  (String, String) _getTrophyInfo() {
    switch (rank) {
      case 1:
        return ('🥇', '1st place - Gold medal');
      case 2:
        return ('🥈', '2nd place - Silver medal');
      case 3:
        return ('🥉', '3rd place - Bronze medal');
      default:
        return ('', 'Rank $rank');
    }
  }
}

/// A badge widget displaying step count.
class _StepsBadge extends StatelessWidget {
  const _StepsBadge({required this.steps});

  final int steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_walk,
            size: 14,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            _formatSteps(steps),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats step count with K/M suffix for readability.
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
