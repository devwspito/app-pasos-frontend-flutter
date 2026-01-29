/// Realtime step badge widget with optional live pulse animation.
///
/// This widget displays a step count badge that can optionally pulse
/// to indicate live/realtime updates.
library;

import 'package:flutter/material.dart';

/// A badge widget displaying step count with optional live animation.
///
/// Shows the current step count with a walking icon. When [isLive] is true,
/// displays a pulsing animation and a green live indicator dot.
///
/// Example usage:
/// ```dart
/// RealtimeStepBadge(
///   steps: 12500,
///   isLive: true,
///   lastUpdated: DateTime.now(),
/// )
/// ```
class RealtimeStepBadge extends StatefulWidget {
  /// Creates a [RealtimeStepBadge].
  ///
  /// The [steps] parameter is required.
  const RealtimeStepBadge({
    required this.steps,
    this.isLive = false,
    this.lastUpdated,
    super.key,
  });

  /// The current step count to display.
  final int steps;

  /// Whether to show live animation indicators.
  ///
  /// When true, displays a pulsing animation and a green live dot.
  final bool isLive;

  /// The timestamp of the last step update.
  ///
  /// Can be used for display purposes or freshness indication.
  final DateTime? lastUpdated;

  @override
  State<RealtimeStepBadge> createState() => _RealtimeStepBadgeState();
}

class _RealtimeStepBadgeState extends State<RealtimeStepBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isLive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RealtimeStepBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive != oldWidget.isLive) {
      if (widget.isLive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Formats step count with K/M suffix for thousands/millions.
  String _formatSteps(int steps) {
    if (steps >= 1000000) {
      final m = steps / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    }
    if (steps >= 1000) {
      final k = steps / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return steps.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final badgeContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live indicator dot
          if (widget.isLive) ...[
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          // Walking icon
          Icon(
            Icons.directions_walk,
            size: 14,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          // Step count text
          Text(
            _formatSteps(widget.steps),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    // Apply pulse animation when live
    if (widget.isLive) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: badgeContent,
      );
    }

    return badgeContent;
  }
}
