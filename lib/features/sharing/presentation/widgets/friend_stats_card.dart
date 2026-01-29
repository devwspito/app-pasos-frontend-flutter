/// Friend stats card widget for displaying friend step statistics.
///
/// This widget shows a friend's step statistics across different
/// time periods in a grid format with optional online status indicator.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/friend_stats.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/widgets/friend_avatar.dart';
import 'package:app_pasos_frontend/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// A card widget that displays a friend's step statistics.
///
/// Shows the friend's avatar with online status and name at the top,
/// followed by a grid of stats: Today, Week, Month, and All-Time.
///
/// Example usage:
/// ```dart
/// FriendStatsCard(
///   friend: sharedUser,
///   stats: friendStats,
///   isOnline: true,
/// )
/// ```
class FriendStatsCard extends StatelessWidget {
  /// Creates a [FriendStatsCard].
  ///
  /// Both [friend] and [stats] parameters are required.
  const FriendStatsCard({
    required this.friend,
    required this.stats,
    this.isOnline,
    super.key,
  });

  /// The friend whose stats are displayed.
  final SharedUser friend;

  /// The step statistics to display.
  final FriendStats stats;

  /// Whether the friend is currently online.
  ///
  /// When null, no online status indicator is displayed.
  /// When true/false, shows the appropriate status indicator.
  final bool? isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Friend header with online status
          Row(
            children: [
              FriendAvatar(
                imageUrl: friend.avatarUrl,
                name: friend.name,
                isOnline: isOnline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  friend.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats grid (2x2)
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Today',
                  value: stats.todaySteps,
                  icon: Icons.today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  label: 'Week',
                  value: stats.weekSteps,
                  icon: Icons.date_range,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Month',
                  value: stats.monthSteps,
                  icon: Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  label: 'All-Time',
                  value: stats.allTimeSteps,
                  icon: Icons.emoji_events,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single stat item widget displaying label, icon, and value.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatSteps(value),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats step count with K/M suffix for thousands/millions.
  String _formatSteps(int steps) {
    if (steps >= 1000000) {
      final m = steps / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    } else if (steps >= 1000) {
      final k = steps / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return steps.toString();
  }
}
