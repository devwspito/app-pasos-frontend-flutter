/// Step counter card widget for displaying today's step progress.
///
/// This widget shows a circular progress indicator with the current
/// step count and goal, using a prominent visual design.
library;

import 'dart:math' as math;

import 'package:app_pasos_frontend/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// A card widget that displays the current step count with circular progress.
///
/// Features:
/// - Circular progress indicator showing progress towards goal
/// - Large centered step count
/// - Subtitle showing steps out of goal
/// - Percentage completion display
///
/// Example usage:
/// ```dart
/// StepCounterCard(
///   currentSteps: 7500,
///   goal: 10000,
/// )
/// ```
class StepCounterCard extends StatelessWidget {
  /// Creates a [StepCounterCard].
  ///
  /// [currentSteps] - The number of steps completed today.
  /// [goal] - The daily step goal.
  const StepCounterCard({
    required this.currentSteps,
    required this.goal,
    super.key,
  });

  /// The number of steps completed today.
  final int currentSteps;

  /// The daily step goal.
  final int goal;

  /// Calculates the progress percentage (0.0 to 1.0).
  double get progress => goal > 0 ? (currentSteps / goal).clamp(0.0, 1.0) : 0.0;

  /// Calculates the percentage as an integer (0 to 100+).
  int get percentage => goal > 0 ? ((currentSteps / goal) * 100).round() : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            "Today's Steps",
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Circular progress indicator with step count
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
                  child: CustomPaint(
                    painter: _CircularProgressPainter(
                      progress: progress,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      progressColor: colorScheme.primary,
                      strokeWidth: 12,
                    ),
                  ),
                ),

                // Step count and info
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current steps
                    Text(
                      _formatNumber(currentSteps),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),

                    // Goal subtitle
                    Text(
                      'of ${_formatNumber(goal)} steps',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Percentage completed
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$percentage% completed',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Goal reached indicator
          if (currentSteps >= goal) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Goal reached!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Formats a number with thousand separators.
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

/// Custom painter for drawing a circular progress indicator.
class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  /// The progress value from 0.0 to 1.0.
  final double progress;

  /// The color of the background arc.
  final Color backgroundColor;

  /// The color of the progress arc.
  final Color progressColor;

  /// The width of the stroke.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // Start from top
    const sweepAngle = 2 * math.pi;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
