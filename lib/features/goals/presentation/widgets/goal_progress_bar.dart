import 'package:flutter/material.dart';

/// A horizontal progress bar widget that displays step progress toward a goal.
///
/// Changes color based on progress:
/// - Red: < 50%
/// - Yellow/Amber: < 80%
/// - Green: >= 80%
///
/// Example:
/// ```dart
/// GoalProgressBar(
///   currentSteps: 7500,
///   targetSteps: 10000,
///   label: 'Weekly Progress',
/// )
/// ```
class GoalProgressBar extends StatelessWidget {
  /// Creates a [GoalProgressBar] widget.
  ///
  /// [currentSteps] is the current number of steps achieved.
  /// [targetSteps] is the target number of steps for the goal.
  /// [label] is an optional label displayed above the progress bar.
  const GoalProgressBar({
    super.key,
    required this.currentSteps,
    required this.targetSteps,
    this.label,
  });

  /// The current number of steps achieved.
  final int currentSteps;

  /// The target number of steps for the goal.
  final int targetSteps;

  /// Optional label displayed above the progress bar.
  final String? label;

  /// Calculates the progress percentage (0.0 to 1.0).
  double get _progress {
    if (targetSteps <= 0) return 0.0;
    return (currentSteps / targetSteps).clamp(0.0, 1.0);
  }

  /// Returns the progress as a percentage integer (0-100).
  int get _percentageInt => (_progress * 100).round();

  /// Returns the color based on progress level.
  ///
  /// - Red: < 50%
  /// - Amber: < 80%
  /// - Green: >= 80%
  Color _getProgressColor(ColorScheme colorScheme) {
    if (_progress < 0.5) {
      return colorScheme.error;
    } else if (_progress < 0.8) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressColor = _getProgressColor(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 45,
              child: Text(
                '$_percentageInt%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatNumber(currentSteps)} / ${_formatNumber(targetSteps)} steps',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
