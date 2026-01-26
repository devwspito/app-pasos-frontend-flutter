import 'package:flutter/material.dart';
import 'package:app_pasos_frontend/core/widgets/app_card.dart';
import 'goal_progress_bar.dart';

/// Status enumeration for goals.
enum GoalStatus {
  /// Goal is currently active and in progress.
  active,

  /// Goal has been completed successfully.
  completed,

  /// Goal was not completed before the end date.
  failed,

  /// Goal is scheduled to start in the future.
  upcoming,
}

/// Domain entity representing a group goal.
///
/// This is used by goal-related widgets to display goal information.
class Goal {
  /// Unique identifier for the goal.
  final String id;

  /// Name/title of the goal.
  final String name;

  /// Optional description of the goal.
  final String? description;

  /// Target number of steps to achieve.
  final int targetSteps;

  /// Current total steps achieved by all members.
  final int currentSteps;

  /// Start date of the goal period.
  final DateTime startDate;

  /// End date of the goal period.
  final DateTime endDate;

  /// Current status of the goal.
  final GoalStatus status;

  /// Creates a [Goal] instance.
  const Goal({
    required this.id,
    required this.name,
    this.description,
    required this.targetSteps,
    required this.currentSteps,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  /// Calculates the progress percentage (0.0 to 1.0).
  double get progress {
    if (targetSteps <= 0) return 0.0;
    return (currentSteps / targetSteps).clamp(0.0, 1.0);
  }

  /// Returns the progress as a percentage integer (0-100).
  int get progressPercentage => (progress * 100).round();

  /// Returns the number of days remaining until the goal ends.
  ///
  /// Returns 0 if the goal has already ended.
  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Returns true if the goal is still active (not ended).
  bool get isActive => status == GoalStatus.active;

  /// Returns true if the goal has been completed.
  bool get isCompleted => status == GoalStatus.completed;
}

/// A card widget that displays goal information.
///
/// Uses [AppCard] as the base container and shows:
/// - Goal name
/// - Target steps
/// - Progress percentage with [GoalProgressBar]
/// - Days remaining
/// - Status badge
///
/// Example:
/// ```dart
/// GoalCard(
///   goal: myGoal,
///   onTap: () => navigateToGoalDetails(myGoal.id),
/// )
/// ```
class GoalCard extends StatelessWidget {
  /// Creates a [GoalCard] widget.
  ///
  /// [goal] is the goal to display.
  /// [onTap] is an optional callback when the card is tapped.
  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  /// The goal to display.
  final Goal goal;

  /// Callback invoked when the card is tapped.
  final VoidCallback? onTap;

  /// Returns the color for the status badge based on goal status.
  Color _getStatusColor(ColorScheme colorScheme) {
    switch (goal.status) {
      case GoalStatus.active:
        return colorScheme.primary;
      case GoalStatus.completed:
        return Colors.green;
      case GoalStatus.failed:
        return colorScheme.error;
      case GoalStatus.upcoming:
        return Colors.amber;
    }
  }

  /// Returns the label text for the status badge.
  String _getStatusLabel() {
    switch (goal.status) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.failed:
        return 'Failed';
      case GoalStatus.upcoming:
        return 'Upcoming';
    }
  }

  /// Returns the icon for the status.
  IconData _getStatusIcon() {
    switch (goal.status) {
      case GoalStatus.active:
        return Icons.directions_walk;
      case GoalStatus.completed:
        return Icons.check_circle;
      case GoalStatus.failed:
        return Icons.cancel;
      case GoalStatus.upcoming:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(colorScheme);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Goal name and status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (goal.description != null &&
                        goal.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(
                label: _getStatusLabel(),
                icon: _getStatusIcon(),
                color: statusColor,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          GoalProgressBar(
            currentSteps: goal.currentSteps,
            targetSteps: goal.targetSteps,
          ),

          const SizedBox(height: 12),

          // Footer: Target and days remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(
                icon: Icons.flag,
                label: '${_formatNumber(goal.targetSteps)} steps',
                colorScheme: colorScheme,
              ),
              if (goal.isActive)
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: '${goal.daysRemaining} days left',
                  colorScheme: colorScheme,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats a number with thousands separators.
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

/// A small badge widget displaying the goal status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small chip displaying an icon and label.
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
