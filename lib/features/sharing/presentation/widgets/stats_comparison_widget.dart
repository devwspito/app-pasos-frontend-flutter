import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

/// Stats data for comparison between users.
class UserStats {
  const UserStats({
    required this.todaySteps,
    required this.goalProgress,
    required this.weeklyAverage,
  });

  /// Today's step count.
  final int todaySteps;

  /// Goal progress as a percentage (0-100+).
  final double goalProgress;

  /// Average steps per day over the past week.
  final int weeklyAverage;
}

/// A widget that displays a side-by-side stats comparison.
///
/// Shows your stats vs a friend's stats with visual indicators
/// for who is "winning" in each category.
///
/// Example usage:
/// ```dart
/// StatsComparisonWidget(
///   myStats: myUserStats,
///   friendStats: friendUserStats,
///   friendName: 'John',
/// )
/// ```
class StatsComparisonWidget extends StatelessWidget {
  /// Creates a [StatsComparisonWidget].
  const StatsComparisonWidget({
    required this.myStats,
    required this.friendStats,
    required this.friendName,
    super.key,
  });

  /// The current user's stats.
  final UserStats myStats;

  /// The friend's stats.
  final UserStats friendStats;

  /// The friend's name for display.
  final String friendName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      elevation: AppCardElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Stats Comparison',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Column headers
          _buildColumnHeaders(colorScheme, textTheme),
          SizedBox(height: AppSpacing.md),

          // Today's steps
          _buildStatRow(
            context: context,
            label: "Today's Steps",
            myValue: myStats.todaySteps,
            friendValue: friendStats.todaySteps,
            formatter: _formatSteps,
          ),
          SizedBox(height: AppSpacing.md),

          // Goal progress
          _buildProgressRow(
            context: context,
            label: 'Goal Progress',
            myProgress: myStats.goalProgress,
            friendProgress: friendStats.goalProgress,
          ),
          SizedBox(height: AppSpacing.md),

          // Weekly average
          _buildStatRow(
            context: context,
            label: 'Weekly Average',
            myValue: myStats.weeklyAverage,
            friendValue: friendStats.weeklyAverage,
            formatter: _formatSteps,
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        // Label column
        Expanded(
          flex: 2,
          child: SizedBox.shrink(),
        ),
        // Your stats column
        Expanded(
          flex: 2,
          child: Text(
            'You',
            textAlign: TextAlign.center,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Friend stats column
        Expanded(
          flex: 2,
          child: Text(
            friendName,
            textAlign: TextAlign.center,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required BuildContext context,
    required String label,
    required int myValue,
    required int friendValue,
    required String Function(int) formatter,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isMyWinning = myValue > friendValue;
    final isFriendWinning = friendValue > myValue;
    final isTied = myValue == friendValue;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Your value
          Expanded(
            flex: 2,
            child: _buildValueCell(
              context: context,
              value: formatter(myValue),
              isWinning: isMyWinning,
              isTied: isTied,
              isPrimary: true,
            ),
          ),
          // Friend value
          Expanded(
            flex: 2,
            child: _buildValueCell(
              context: context,
              value: formatter(friendValue),
              isWinning: isFriendWinning,
              isTied: isTied,
              isPrimary: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required BuildContext context,
    required String label,
    required double myProgress,
    required double friendProgress,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isMyWinning = myProgress > friendProgress;
    final isFriendWinning = friendProgress > myProgress;
    final isTied = myProgress == friendProgress;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Your progress
          Expanded(
            flex: 2,
            child: _buildProgressCell(
              context: context,
              progress: myProgress,
              isWinning: isMyWinning,
              isTied: isTied,
              isPrimary: true,
            ),
          ),
          // Friend progress
          Expanded(
            flex: 2,
            child: _buildProgressCell(
              context: context,
              progress: friendProgress,
              isWinning: isFriendWinning,
              isTied: isTied,
              isPrimary: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCell({
    required BuildContext context,
    required String value,
    required bool isWinning,
    required bool isTied,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color textColor;
    if (isWinning) {
      textColor = isPrimary ? colorScheme.primary : colorScheme.secondary;
    } else if (isTied) {
      textColor = colorScheme.onSurface;
    } else {
      textColor = colorScheme.onSurfaceVariant;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isWinning)
          Icon(
            Icons.emoji_events_rounded,
            size: 14,
            color: textColor,
          ),
        if (isWinning) SizedBox(width: AppSpacing.xxs),
        Text(
          value,
          textAlign: TextAlign.center,
          style: textTheme.titleSmall?.copyWith(
            color: textColor,
            fontWeight: isWinning ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCell({
    required BuildContext context,
    required double progress,
    required bool isWinning,
    required bool isTied,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color progressColor;
    Color textColor;
    if (isWinning) {
      progressColor = isPrimary ? colorScheme.primary : colorScheme.secondary;
      textColor = progressColor;
    } else if (isTied) {
      progressColor = colorScheme.outline;
      textColor = colorScheme.onSurface;
    } else {
      progressColor = colorScheme.outlineVariant;
      textColor = colorScheme.onSurfaceVariant;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWinning)
              Icon(
                Icons.emoji_events_rounded,
                size: 12,
                color: textColor,
              ),
            if (isWinning) SizedBox(width: AppSpacing.xxs),
            Text(
              '${progress.toInt()}%',
              style: textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: isWinning ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: AppSpacing.borderRadiusPill,
          child: LinearProgressIndicator(
            value: (progress / 100).clamp(0.0, 1.0),
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }
}
