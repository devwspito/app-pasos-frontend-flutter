import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

/// A card widget that displays the current step count with a circular progress indicator.
///
/// Shows the user's progress towards their daily step goal with:
/// - A circular progress indicator showing percentage complete
/// - The current step count prominently displayed
/// - A linear progress bar for quick visual reference
/// - Percentage of goal completed
///
/// Example:
/// ```dart
/// StepCounterCard(
///   stepCount: 5420,
///   goalSteps: 10000,
///   goalProgress: 0.542,
/// )
/// ```
class StepCounterCard extends StatelessWidget {
  /// Creates a [StepCounterCard] widget.
  ///
  /// All parameters are required:
  /// - [stepCount]: The current number of steps taken today
  /// - [goalSteps]: The daily step goal
  /// - [goalProgress]: Progress towards the goal as a value between 0.0 and 1.0
  const StepCounterCard({
    super.key,
    required this.stepCount,
    required this.goalSteps,
    required this.goalProgress,
  });

  /// The current number of steps taken today.
  final int stepCount;

  /// The daily step goal.
  final int goalSteps;

  /// Progress towards the goal as a value between 0.0 and 1.0.
  ///
  /// This should be calculated as `stepCount / goalSteps` clamped to [0.0, 1.0].
  final double goalProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Clamp progress to valid range
    final clampedProgress = goalProgress.clamp(0.0, 1.0);
    final progressPercent = (clampedProgress * 100).toInt();

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            "Today's Steps",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Circular Progress with Step Count
          Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress indicator
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: clampedProgress,
                  strokeWidth: 12,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(clampedProgress, colorScheme),
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Step count text in center
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatStepCount(stepCount),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'of ${_formatStepCount(goalSteps)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(clampedProgress, colorScheme),
              ),
              minHeight: 8,
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Percentage text
          Text(
            '$progressPercent% of daily goal',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          // Achievement indicator when goal is met
          if (clampedProgress >= 1.0) ...[
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    size: AppSpacing.iconSm,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Goal Achieved!',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
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

  /// Returns the progress color based on completion percentage.
  ///
  /// - Red/error for low progress (<25%)
  /// - Orange/warning for moderate progress (25-50%)
  /// - Yellow for good progress (50-75%)
  /// - Green/primary for excellent progress (>75%)
  Color _getProgressColor(double progress, ColorScheme colorScheme) {
    if (progress >= 0.75) {
      return colorScheme.primary;
    } else if (progress >= 0.50) {
      return Colors.amber;
    } else if (progress >= 0.25) {
      return Colors.orange;
    } else {
      return colorScheme.error;
    }
  }

  /// Formats the step count with thousands separators for readability.
  String _formatStepCount(int count) {
    if (count < 1000) {
      return count.toString();
    }

    // Format with comma separators
    final String countStr = count.toString();
    final StringBuffer result = StringBuffer();
    int counter = 0;

    for (int i = countStr.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result.write(',');
        counter = 0;
      }
      result.write(countStr[i]);
      counter++;
    }

    return result.toString().split('').reversed.join();
  }
}
