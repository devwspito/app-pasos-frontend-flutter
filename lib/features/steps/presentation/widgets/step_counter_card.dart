import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../../../core/theme/app_spacing.dart';

/// A card widget displaying step count with a circular progress indicator.
///
/// Shows the current step count relative to the goal with a visual
/// circular progress indicator and percentage display.
///
/// Example usage:
/// ```dart
/// StepCounterCard(
///   currentSteps: 7500,
///   goalSteps: 10000,
/// )
/// ```
class StepCounterCard extends StatelessWidget {
  /// Creates a StepCounterCard.
  ///
  /// [currentSteps] is the number of steps taken today.
  /// [goalSteps] is the daily step goal.
  const StepCounterCard({
    required this.currentSteps,
    required this.goalSteps,
    this.onTap,
    super.key,
  });

  /// Current number of steps taken today
  final int currentSteps;

  /// Daily step goal
  final int goalSteps;

  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Calculate progress percentage (0.0 to 1.0, capped at 1.0 for display)
    final progress = goalSteps > 0
        ? (currentSteps / goalSteps).clamp(0.0, 1.0)
        : 0.0;

    // Calculate display percentage (can exceed 100%)
    final displayPercent = goalSteps > 0
        ? (currentSteps / goalSteps * 100).toInt()
        : 0;

    final isGoalAchieved = currentSteps >= goalSteps;

    // Dynamic color based on goal achievement
    final progressColor = isGoalAchieved
        ? colorScheme.tertiary
        : colorScheme.primary;

    return AppCard(
      elevation: AppCardElevation.medium,
      onTap: onTap,
      padding: AppSpacing.allLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'Today\'s Steps',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Circular progress indicator
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step count
                    Text(
                      _formatNumber(currentSteps),
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    // Goal
                    Text(
                      'of ${_formatNumber(goalSteps)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    // Percentage badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.15),
                        borderRadius: AppSpacing.borderRadiusPill,
                      ),
                      child: Text(
                        '$displayPercent%',
                        style: textTheme.labelLarge?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Goal achieved indicator
          if (isGoalAchieved)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration_rounded,
                    color: colorScheme.onTertiaryContainer,
                    size: AppSpacing.iconMd,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Goal Achieved!',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
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
}
