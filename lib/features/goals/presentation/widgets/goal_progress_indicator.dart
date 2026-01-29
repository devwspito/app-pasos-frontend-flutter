/// Goal progress indicator widget for displaying goal completion.
///
/// This widget provides a circular progress indicator showing the
/// percentage of goal completion with color-coded feedback.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular progress indicator that displays goal completion percentage.
///
/// Shows a circular progress bar with the percentage displayed in the center.
/// The color changes based on the progress level:
/// - Green (>= 80%): Goal is nearly complete
/// - Yellow (50-79%): Good progress
/// - Red (< 50%): Needs more effort
///
/// Example usage:
/// ```dart
/// GoalProgressIndicator(
///   progress: 75.0,
///   size: 64,
///   animate: true,
///   animationDuration: Duration(milliseconds: 800),
/// )
/// ```
class GoalProgressIndicator extends StatelessWidget {
  /// Creates a [GoalProgressIndicator].
  ///
  /// The [progress] should be a value between 0 and 100.
  const GoalProgressIndicator({
    required this.progress,
    this.size = 48,
    this.strokeWidth = 6,
    this.backgroundColor,
    this.showPercentage = true,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 800),
    super.key,
  });

  /// The progress percentage (0-100).
  final double progress;

  /// The diameter of the indicator.
  ///
  /// Defaults to 48.
  final double size;

  /// The stroke width of the progress arc.
  ///
  /// Defaults to 6.
  final double strokeWidth;

  /// Optional background color for the track.
  ///
  /// When null, uses a semi-transparent version of the progress color.
  final Color? backgroundColor;

  /// Whether to show the percentage text in the center.
  ///
  /// Defaults to true.
  final bool showPercentage;

  /// Whether to animate the progress arc drawing.
  ///
  /// When true, the progress arc animates from 0 to the target value
  /// when first built. Defaults to false for backward compatibility.
  final bool animate;

  /// Duration of the animation when [animate] is true.
  ///
  /// Defaults to 800 milliseconds.
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Clamp progress to 0-100 range
    final clampedProgress = progress.clamp(0.0, 100.0);

    final progressColor = _getProgressColor(colorScheme, clampedProgress);
    final trackColor = backgroundColor ??
        colorScheme.surfaceContainerHighest.withOpacity(0.5);

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clampedProgress / 100.0),
        duration: animationDuration,
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return _buildIndicator(
            theme: theme,
            progressRatio: animatedProgress,
            displayProgress: animatedProgress * 100,
            progressColor: progressColor,
            trackColor: trackColor,
          );
        },
      );
    }

    return _buildIndicator(
      theme: theme,
      progressRatio: clampedProgress / 100.0,
      displayProgress: clampedProgress,
      progressColor: progressColor,
      trackColor: trackColor,
    );
  }

  /// Builds the indicator widget with the given parameters.
  Widget _buildIndicator({
    required ThemeData theme,
    required double progressRatio,
    required double displayProgress,
    required Color progressColor,
    required Color trackColor,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressPainter(
              progress: progressRatio,
              progressColor: progressColor,
              trackColor: trackColor,
              strokeWidth: strokeWidth,
            ),
          ),

          // Center content
          if (showPercentage)
            Text(
              '${displayProgress.toInt()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.bold,
                fontSize: _calculateFontSize(),
              ),
            ),
        ],
      ),
    );
  }

  /// Calculates the appropriate font size based on indicator size.
  double _calculateFontSize() {
    if (size < 40) return 8;
    if (size < 56) return 10;
    if (size < 72) return 12;
    return 14;
  }

  /// Returns the color based on progress percentage.
  ///
  /// - Green for >= 80% (goal nearly complete)
  /// - Yellow for 50-79% (good progress)
  /// - Red for < 50% (needs improvement)
  Color _getProgressColor(ColorScheme colorScheme, double progress) {
    if (progress >= 80) {
      return _successColor;
    } else if (progress >= 50) {
      return _warningColor;
    } else {
      return colorScheme.error;
    }
  }

  /// Green color for high progress.
  static const Color _successColor = Color(0xFF4CAF50);

  /// Yellow/Amber color for medium progress.
  static const Color _warningColor = Color(0xFFFFC107);
}

/// Custom painter for drawing the circular progress indicator.
class _ProgressPainter extends CustomPainter {
  _ProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw track (background circle)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Start from the top (-90 degrees)
      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
