import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'progress_ring.dart';

/// A step counter display widget showing current steps with goal comparison.
///
/// Features animated number changes and a circular progress indicator.
/// Uses [AnimatedProgressRing] for smooth progress animations.
///
/// Usage:
/// ```dart
/// StepCounterDisplay(
///   stepCount: 5234,
///   goal: 10000,
/// )
/// ```
///
/// With custom styling:
/// ```dart
/// StepCounterDisplay(
///   stepCount: 7500,
///   goal: 10000,
///   size: 200,
///   progressColor: Colors.green,
///   showGoalLabel: true,
/// )
/// ```
class StepCounterDisplay extends StatelessWidget {
  /// Creates a [StepCounterDisplay] widget.
  ///
  /// Both [stepCount] and [goal] parameters are required.
  /// [goal] must be greater than 0.
  const StepCounterDisplay({
    super.key,
    required this.stepCount,
    required this.goal,
    this.size = 180,
    this.strokeWidth = 12.0,
    this.progressColor,
    this.backgroundColor,
    this.stepCountStyle,
    this.goalLabelStyle,
    this.showGoalLabel = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
    this.labelBuilder,
  }) : assert(goal > 0, 'Goal must be greater than 0');

  /// The current step count to display.
  final int stepCount;

  /// The step goal for comparison.
  final int goal;

  /// The overall size of the display widget.
  final double size;

  /// The stroke width of the progress ring.
  final double strokeWidth;

  /// The color of the progress arc.
  /// When null, uses theme primary or success color based on goal completion.
  final Color? progressColor;

  /// The color of the background ring.
  final Color? backgroundColor;

  /// Text style for the step count number.
  /// When null, uses headline medium with primary color.
  final TextStyle? stepCountStyle;

  /// Text style for the goal label.
  /// When null, uses body small with secondary color.
  final TextStyle? goalLabelStyle;

  /// Whether to show the goal label below the step count.
  final bool showGoalLabel;

  /// Duration of the number animation.
  final Duration animationDuration;

  /// Curve of the animation.
  final Curve animationCurve;

  /// Custom builder for the center label.
  /// If provided, overrides the default step count and goal display.
  final Widget Function(BuildContext context, int steps, int goal)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (stepCount / goal).clamp(0.0, 1.0);
    final isGoalReached = stepCount >= goal;

    // Determine progress color based on goal completion
    final effectiveProgressColor = progressColor ??
        (isGoalReached
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary);

    return Semantics(
      label: 'Step counter',
      value: '$stepCount steps of $goal goal',
      child: AnimatedProgressRing(
        progress: progress,
        size: size,
        strokeWidth: strokeWidth,
        progressColor: effectiveProgressColor,
        backgroundColor: backgroundColor,
        duration: animationDuration,
        curve: animationCurve,
        child: labelBuilder != null
            ? labelBuilder!(context, stepCount, goal)
            : _buildDefaultLabel(context, theme, isGoalReached),
      ),
    );
  }

  Widget _buildDefaultLabel(
    BuildContext context,
    ThemeData theme,
    bool isGoalReached,
  ) {
    final effectiveStepStyle = stepCountStyle ??
        theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: isGoalReached
              ? theme.colorScheme.tertiary
              : theme.colorScheme.primary,
        );

    final effectiveGoalStyle = goalLabelStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedStepCount(
          stepCount: stepCount,
          duration: animationDuration,
          style: effectiveStepStyle,
        ),
        if (showGoalLabel) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'of $goal',
            style: effectiveGoalStyle,
          ),
          if (isGoalReached) ...[
            const SizedBox(height: AppSpacing.xxs),
            Icon(
              Icons.check_circle,
              size: 16,
              color: theme.colorScheme.tertiary,
            ),
          ],
        ],
      ],
    );
  }
}

/// Internal widget for animating the step count number.
class _AnimatedStepCount extends StatelessWidget {
  const _AnimatedStepCount({
    required this.stepCount,
    required this.duration,
    this.style,
  });

  final int stepCount;
  final Duration duration;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: stepCount),
      duration: duration,
      builder: (context, value, _) {
        return Text(
          _formatNumber(value),
          style: style,
          semanticsLabel: '$value steps',
        );
      },
    );
  }

  /// Formats the number with thousand separators.
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();

    final str = number.toString();
    final buffer = StringBuffer();
    final length = str.length;

    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }
}

/// A compact step counter that shows steps with a linear progress indicator.
///
/// Suitable for smaller display areas like list items or cards.
///
/// Usage:
/// ```dart
/// CompactStepCounter(
///   stepCount: 3500,
///   goal: 10000,
/// )
/// ```
class CompactStepCounter extends StatelessWidget {
  /// Creates a [CompactStepCounter] widget.
  const CompactStepCounter({
    super.key,
    required this.stepCount,
    required this.goal,
    this.height = 4.0,
    this.progressColor,
    this.backgroundColor,
    this.showLabel = true,
    this.labelStyle,
  }) : assert(goal > 0, 'Goal must be greater than 0');

  /// The current step count.
  final int stepCount;

  /// The step goal.
  final int goal;

  /// Height of the progress bar.
  final double height;

  /// Color of the progress indicator.
  final Color? progressColor;

  /// Color of the progress background.
  final Color? backgroundColor;

  /// Whether to show the step count label.
  final bool showLabel;

  /// Style for the label text.
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (stepCount / goal).clamp(0.0, 1.0);
    final isGoalReached = stepCount >= goal;

    final effectiveProgressColor = progressColor ??
        (isGoalReached
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary);

    final effectiveBackgroundColor = backgroundColor ??
        effectiveProgressColor.withValues(alpha: 0.2);

    final effectiveLabelStyle = labelStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );

    return Semantics(
      label: 'Step progress',
      value: '$stepCount of $goal steps',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatNumber(stepCount),
                  style: effectiveLabelStyle,
                ),
                Text(
                  '/ $_formattedGoal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: LinearProgressIndicator(
                  value: animatedProgress,
                  minHeight: height,
                  backgroundColor: effectiveBackgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    effectiveProgressColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String get _formattedGoal => _formatNumber(goal);

  String _formatNumber(int number) {
    if (number < 1000) return number.toString();

    final str = number.toString();
    final buffer = StringBuffer();
    final length = str.length;

    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }
}
