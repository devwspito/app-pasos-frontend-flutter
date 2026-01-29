/// Goal card widget for displaying group goal information.
///
/// This widget provides a tappable card showing goal details
/// including name, description, progress, and status.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/goal_progress.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:app_pasos_frontend/features/goals/presentation/widgets/goal_progress_indicator.dart';
import 'package:app_pasos_frontend/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// A card widget that displays a group goal's information.
///
/// Shows the goal's name, description, progress indicator, and status.
/// Supports tap and long-press interactions for navigation and quick actions.
///
/// Example usage:
/// ```dart
/// GoalCard(
///   goal: groupGoal,
///   progress: goalProgress,
///   onTap: () => navigateToGoalDetails(),
///   onLongPress: () => showQuickActionsMenu(),
///   lastUpdated: DateTime.now(),
/// )
/// ```
class GoalCard extends StatelessWidget {
  /// Creates a [GoalCard].
  ///
  /// The [goal] and [onTap] parameters are required.
  const GoalCard({
    required this.goal,
    required this.onTap,
    this.progress,
    this.onLongPress,
    this.lastUpdated,
    super.key,
  });

  /// The group goal to display.
  final GroupGoal goal;

  /// Optional progress information for the goal.
  final GoalProgress? progress;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Optional callback when the card is long-pressed.
  ///
  /// Use this for showing quick actions like edit, share, or delete.
  final VoidCallback? onLongPress;

  /// Optional timestamp of the last update.
  ///
  /// When provided, displays a relative time indicator (e.g., "Updated 5m ago").
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget card = AppCard(
      onTap: onLongPress != null ? null : onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          GoalProgressIndicator(
            progress: progress?.progressPercentage ?? 0,
            size: 56,
          ),
          const SizedBox(width: 16),

          // Goal details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Goal name with optional timestamp
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lastUpdated != null) ...[
                      const SizedBox(width: 8),
                      _LastUpdatedBadge(timestamp: lastUpdated!),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Goal description
                if (goal.hasDescription) ...[
                  Text(
                    goal.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],

                // Progress info
                Row(
                  children: [
                    _StepsBadge(
                      currentSteps: progress?.currentSteps ?? 0,
                      targetSteps: goal.targetSteps,
                    ),
                    const Spacer(),
                    _StatusBadge(status: goal.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Wrap with GestureDetector if onLongPress is provided
    if (onLongPress != null) {
      card = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    return card;
  }
}

/// A badge widget displaying the last updated timestamp.
class _LastUpdatedBadge extends StatelessWidget {
  const _LastUpdatedBadge({required this.timestamp});

  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.update,
          size: 12,
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        const SizedBox(width: 2),
        Text(
          _formatRelativeTime(timestamp),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// Formats a timestamp as a relative time string.
  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '${mins}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '${days}d ago';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    }
  }
}

/// A badge widget displaying step progress.
class _StepsBadge extends StatelessWidget {
  const _StepsBadge({
    required this.currentSteps,
    required this.targetSteps,
  });

  final int currentSteps;
  final int targetSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.directions_walk,
          size: 14,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '${_formatSteps(currentSteps)} / ${_formatSteps(targetSteps)}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Formats step count with K suffix for thousands.
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

/// A badge widget displaying goal status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (backgroundColor, textColor, icon) = _getStatusStyle(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the style tuple for the current status.
  (Color, Color, IconData) _getStatusStyle(ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'active':
        return (
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
          Icons.play_circle_outline,
        );
      case 'completed':
        return (
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
          Icons.check_circle_outline,
        );
      case 'cancelled':
        return (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
          Icons.cancel_outlined,
        );
      default:
        return (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
          Icons.info_outline,
        );
    }
  }

  /// Returns the display label for the current status.
  String _getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Done';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
