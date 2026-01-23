import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular progress ring widget that displays progress visually.
///
/// Uses [CustomPainter] to draw a circular progress indicator with
/// customizable colors, stroke width, and animation support.
///
/// Usage:
/// ```dart
/// ProgressRing(
///   progress: 0.75,  // 75% progress
///   size: 120,
///   strokeWidth: 8,
///   progressColor: Colors.green,
/// )
/// ```
///
/// With animation:
/// ```dart
/// TweenAnimationBuilder<double>(
///   tween: Tween(begin: 0, end: targetProgress),
///   duration: Duration(milliseconds: 800),
///   builder: (context, value, _) => ProgressRing(progress: value),
/// )
/// ```
class ProgressRing extends StatelessWidget {
  /// Creates a [ProgressRing] widget.
  ///
  /// The [progress] value should be between 0.0 and 1.0.
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8.0,
    this.progressColor,
    this.backgroundColor,
    this.startAngle = -math.pi / 2,
    this.child,
    this.strokeCap = StrokeCap.round,
  }) : assert(progress >= 0.0 && progress <= 1.0,
            'Progress must be between 0.0 and 1.0');

  /// The progress value between 0.0 and 1.0.
  final double progress;

  /// The diameter of the progress ring.
  final double size;

  /// The stroke width of the ring.
  final double strokeWidth;

  /// The color of the progress arc.
  /// When null, uses the theme's primary color.
  final Color? progressColor;

  /// The color of the background ring.
  /// When null, uses a semi-transparent version of the progress color.
  final Color? backgroundColor;

  /// The starting angle for the progress arc in radians.
  /// Defaults to -π/2 (top of the circle).
  final double startAngle;

  /// Optional widget to display in the center of the ring.
  final Widget? child;

  /// The stroke cap style for the progress arc.
  /// Defaults to [StrokeCap.round] for rounded ends.
  final StrokeCap strokeCap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveProgressColor = progressColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ??
        effectiveProgressColor.withValues(alpha: 0.2);

    return Semantics(
      label: 'Progress: ${(progress * 100).toInt()} percent',
      value: '${(progress * 100).toInt()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _ProgressRingPainter(
                progress: progress,
                strokeWidth: strokeWidth,
                progressColor: effectiveProgressColor,
                backgroundColor: effectiveBackgroundColor,
                startAngle: startAngle,
                strokeCap: strokeCap,
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

/// Custom painter for drawing the progress ring.
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
    required this.startAngle,
    required this.strokeCap,
  });

  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final double startAngle;
  final StrokeCap strokeCap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;

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
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.strokeCap != strokeCap;
  }
}

/// An animated progress ring that smoothly transitions between values.
///
/// This widget wraps [ProgressRing] with [TweenAnimationBuilder] for
/// smooth animated transitions when the progress value changes.
///
/// Usage:
/// ```dart
/// AnimatedProgressRing(
///   progress: stepCount / stepGoal,
///   duration: Duration(milliseconds: 500),
///   size: 150,
/// )
/// ```
class AnimatedProgressRing extends StatelessWidget {
  /// Creates an [AnimatedProgressRing] widget.
  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.size = 100,
    this.strokeWidth = 8.0,
    this.progressColor,
    this.backgroundColor,
    this.startAngle = -math.pi / 2,
    this.child,
    this.strokeCap = StrokeCap.round,
  }) : assert(progress >= 0.0 && progress <= 1.0,
            'Progress must be between 0.0 and 1.0');

  /// The target progress value between 0.0 and 1.0.
  final double progress;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  /// The diameter of the progress ring.
  final double size;

  /// The stroke width of the ring.
  final double strokeWidth;

  /// The color of the progress arc.
  final Color? progressColor;

  /// The color of the background ring.
  final Color? backgroundColor;

  /// The starting angle for the progress arc.
  final double startAngle;

  /// Optional widget to display in the center.
  final Widget? child;

  /// The stroke cap style.
  final StrokeCap strokeCap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: duration,
      curve: curve,
      builder: (context, animatedProgress, _) {
        return ProgressRing(
          progress: animatedProgress,
          size: size,
          strokeWidth: strokeWidth,
          progressColor: progressColor,
          backgroundColor: backgroundColor,
          startAngle: startAngle,
          strokeCap: strokeCap,
          child: child,
        );
      },
    );
  }
}
