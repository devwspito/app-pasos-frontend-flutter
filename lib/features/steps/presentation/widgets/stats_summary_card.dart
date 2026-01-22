import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../../../core/theme/app_spacing.dart';

/// A card widget displaying step statistics summary.
///
/// Shows weekly average, steps remaining to goal, and goal achievement status.
///
/// Example usage:
/// ```dart
/// StatsSummaryCard(
///   weeklyAverage: 8500.5,
///   stepsRemaining: 2500,
///   isGoalAchieved: false,
/// )
/// ```
class StatsSummaryCard extends StatelessWidget {
  /// Creates a StatsSummaryCard.
  ///
  /// [weeklyAverage] is the average daily steps over the past week.
  /// [stepsRemaining] is the number of steps left to reach today's goal.
  /// [isGoalAchieved] indicates whether today's goal has been met.
  const StatsSummaryCard({
    required this.weeklyAverage,
    required this.stepsRemaining,
    required this.isGoalAchieved,
    this.onTap,
    super.key,
  });

  /// Average daily steps for the past week
  final double weeklyAverage;

  /// Steps remaining to reach today's goal
  final int stepsRemaining;

  /// Whether today's step goal has been achieved
  final bool isGoalAchieved;

  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      elevation: AppCardElevation.low,
      onTap: onTap,
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: colorScheme.primary,
                size: AppSpacing.iconMd,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Statistics',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Stats row
          Row(
            children: [
              // Weekly Average
              Expanded(
                child: _StatItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Weekly Avg',
                  value: _formatNumber(weeklyAverage.round()),
                  color: colorScheme.secondary,
                ),
              ),
              // Vertical divider
              Container(
                height: 50,
                width: 1,
                color: colorScheme.outlineVariant,
              ),
              // Steps Remaining or Goal Status
              Expanded(
                child: isGoalAchieved
                    ? _StatItem(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Status',
                        value: 'Complete',
                        color: colorScheme.tertiary,
                        isSuccess: true,
                      )
                    : _StatItem(
                        icon: Icons.directions_walk_rounded,
                        label: 'To Goal',
                        value: _formatNumber(stepsRemaining),
                        color: colorScheme.primary,
                      ),
              ),
            ],
          ),

          // Progress hint
          if (!isGoalAchieved && stepsRemaining > 0) ...[
            SizedBox(height: AppSpacing.md),
            Container(
              padding: AppSpacing.allSm,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: AppSpacing.iconSm,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _getMotivationalMessage(stepsRemaining),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Formats a number with thousand separators.
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();

    final String numStr = number.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(numStr[i]);
    }

    return result.toString();
  }

  /// Returns a motivational message based on steps remaining.
  String _getMotivationalMessage(int stepsRemaining) {
    if (stepsRemaining <= 1000) {
      return 'Almost there! Just a short walk to reach your goal.';
    } else if (stepsRemaining <= 3000) {
      return 'Keep going! A 20-minute walk will get you there.';
    } else if (stepsRemaining <= 5000) {
      return 'You\'re making progress! A brisk walk will help.';
    } else {
      return 'Every step counts! Start with a short walk.';
    }
  }
}

/// Individual stat item widget used within StatsSummaryCard.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isSuccess = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: AppSpacing.horizontalSm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with background
          Container(
            padding: AppSpacing.allSm,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSpacing.iconMd,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // Value
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSuccess ? color : colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
          // Label
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
