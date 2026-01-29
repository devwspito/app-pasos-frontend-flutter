/// Realtime progress indicator widget with animation support.
///
/// This widget wraps [GoalProgressIndicator] with smooth animations
/// for progress value changes and pulse effects on updates.
library;

import 'package:flutter/material.dart';

import 'package:app_pasos_frontend/features/goals/presentation/widgets/goal_progress_indicator.dart';

/// A progress indicator that animates smoothly when progress changes.
///
/// Wraps [GoalProgressIndicator] with:
/// - Smooth progress value transitions using [TweenAnimationBuilder]
/// - Pulse animation when new update is received
/// - Optional delta display showing step count change
/// - Color flash animation on progress update
///
/// Example usage:
/// ```dart
/// RealtimeProgressIndicator(
///   progress: 75.0,
///   previousProgress: 70.0,
///   size: 64,
///   showDelta: true,
///   deltaSteps: 500,
/// )
/// ```
class RealtimeProgressIndicator extends StatefulWidget {
  /// Creates a [RealtimeProgressIndicator].
  ///
  /// The [progress] should be a value between 0 and 100.
  const RealtimeProgressIndicator({
    required this.progress,
    this.previousProgress,
    this.size = 48,
    this.strokeWidth = 6,
    this.backgroundColor,
    this.showPercentage = true,
    this.showDelta = false,
    this.deltaSteps,
    this.animationDuration = const Duration(milliseconds: 500),
    this.pulseOnUpdate = true,
    super.key,
  });

  /// The current progress percentage (0-100).
  final double progress;

  /// The previous progress percentage for animation.
  ///
  /// When null, animation starts from 0.
  final double? previousProgress;

  /// The diameter of the indicator.
  ///
  /// Defaults to 48.
  final double size;

  /// The stroke width of the progress arc.
  ///
  /// Defaults to 6.
  final double strokeWidth;

  /// Optional background color for the track.
  final Color? backgroundColor;

  /// Whether to show the percentage text in the center.
  ///
  /// Defaults to true.
  final bool showPercentage;

  /// Whether to show the step delta change indicator.
  ///
  /// Defaults to false.
  final bool showDelta;

  /// The number of steps changed (e.g., +500 steps).
  ///
  /// Only displayed when [showDelta] is true.
  final int? deltaSteps;

  /// Duration of the progress animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration animationDuration;

  /// Whether to show pulse effect on update.
  ///
  /// Defaults to true.
  final bool pulseOnUpdate;

  @override
  State<RealtimeProgressIndicator> createState() =>
      _RealtimeProgressIndicatorState();
}

class _RealtimeProgressIndicatorState extends State<RealtimeProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  double _lastProgress = 0;
  bool _showDeltaOverlay = false;

  @override
  void initState() {
    super.initState();
    _lastProgress = widget.previousProgress ?? 0;
    _initPulseAnimation();
  }

  void _initPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_pulseController);
  }

  @override
  void didUpdateWidget(RealtimeProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger pulse animation when progress changes
    if (widget.progress != oldWidget.progress && widget.pulseOnUpdate) {
      _triggerPulse();
    }

    // Show delta overlay when steps change
    if (widget.deltaSteps != null &&
        widget.showDelta &&
        widget.deltaSteps != 0) {
      _showDeltaTemporarily();
    }

    _lastProgress = oldWidget.progress;
  }

  void _triggerPulse() {
    _pulseController.forward(from: 0);
  }

  void _showDeltaTemporarily() {
    setState(() => _showDeltaOverlay = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showDeltaOverlay = false);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main animated progress indicator
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: _lastProgress, end: widget.progress),
            duration: widget.animationDuration,
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, child) {
              return _AnimatedColorWrapper(
                progress: animatedProgress,
                previousProgress: _lastProgress,
                child: GoalProgressIndicator(
                  progress: animatedProgress,
                  size: widget.size,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: widget.backgroundColor,
                  showPercentage: widget.showPercentage,
                  animate: true,
                  animationDuration: widget.animationDuration,
                ),
              );
            },
          ),
        ),

        // Delta steps overlay
        if (_showDeltaOverlay && widget.deltaSteps != null)
          Positioned(
            top: -8,
            right: -8,
            child: _DeltaBadge(
              deltaSteps: widget.deltaSteps!,
              colorScheme: colorScheme,
            ),
          ),
      ],
    );
  }
}

/// Wrapper that adds a color flash effect when progress changes significantly.
class _AnimatedColorWrapper extends StatefulWidget {
  const _AnimatedColorWrapper({
    required this.progress,
    required this.previousProgress,
    required this.child,
  });

  final double progress;
  final double previousProgress;
  final Widget child;

  @override
  State<_AnimatedColorWrapper> createState() => _AnimatedColorWrapperState();
}

class _AnimatedColorWrapperState extends State<_AnimatedColorWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flashAnimation = Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_flashController);
  }

  @override
  void didUpdateWidget(_AnimatedColorWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger flash when progress increases
    if (widget.progress > oldWidget.progress) {
      _flashController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        // Apply subtle glow effect during flash
        final flashOpacity = (1 - _flashAnimation.value) * 0.3;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: flashOpacity > 0.01
                ? [
                    BoxShadow(
                      color: _getProgressColor(widget.progress)
                          .withOpacity(flashOpacity),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  /// Returns the color based on progress percentage.
  Color _getProgressColor(double progress) {
    if (progress >= 80) {
      return const Color(0xFF4CAF50); // Green
    } else if (progress >= 50) {
      return const Color(0xFFFFC107); // Yellow
    } else {
      return const Color(0xFFF44336); // Red
    }
  }
}

/// Badge showing step delta change.
class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({
    required this.deltaSteps,
    required this.colorScheme,
  });

  final int deltaSteps;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = deltaSteps > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPositive
            ? const Color(0xFF4CAF50).withOpacity(0.9)
            : colorScheme.error.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            _formatDelta(deltaSteps),
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats the delta steps with K/M suffix.
  String _formatDelta(int steps) {
    final absSteps = steps.abs();
    final prefix = steps > 0 ? '+' : '-';

    if (absSteps >= 1000000) {
      final m = absSteps / 1000000;
      return '$prefix${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    }
    if (absSteps >= 1000) {
      final k = absSteps / 1000;
      return '$prefix${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return '$prefix$absSteps';
  }
}
