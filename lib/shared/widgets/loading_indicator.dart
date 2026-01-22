import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Size variants for the loading indicator
enum LoadingIndicatorSize {
  /// Small indicator (16x16)
  small,

  /// Medium indicator (32x32) - default
  medium,

  /// Large indicator (48x48)
  large,
}

/// A reusable loading indicator widget following Material Design 3 guidelines.
///
/// Displays a circular progress indicator with optional message text.
/// Supports multiple size variants and customization options.
///
/// Example usage:
/// ```dart
/// LoadingIndicator(
///   size: LoadingIndicatorSize.medium,
///   message: 'Loading data...',
/// )
/// ```
class LoadingIndicator extends StatelessWidget {
  /// Creates a LoadingIndicator.
  const LoadingIndicator({
    this.size = LoadingIndicatorSize.medium,
    this.message,
    this.color,
    this.strokeWidth,
    this.centered = true,
    super.key,
  });

  /// The size variant of the indicator
  final LoadingIndicatorSize size;

  /// Optional message displayed below the indicator
  final String? message;

  /// Custom color for the indicator
  /// If null, uses theme primary color
  final Color? color;

  /// Custom stroke width for the circular indicator
  /// If null, uses default based on size
  final double? strokeWidth;

  /// Whether to center the indicator in available space
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final indicatorSize = _getIndicatorSize();
    final effectiveStrokeWidth = strokeWidth ?? _getStrokeWidth();
    final effectiveColor = color ?? colorScheme.primary;

    Widget indicator = SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: effectiveStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    if (message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (centered) {
      return Center(child: indicator);
    }

    return indicator;
  }

  double _getIndicatorSize() {
    switch (size) {
      case LoadingIndicatorSize.small:
        return 16.0;
      case LoadingIndicatorSize.medium:
        return 32.0;
      case LoadingIndicatorSize.large:
        return 48.0;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingIndicatorSize.small:
        return 2.0;
      case LoadingIndicatorSize.medium:
        return 3.0;
      case LoadingIndicatorSize.large:
        return 4.0;
    }
  }
}

/// A full-screen loading overlay widget.
///
/// Displays a loading indicator over a semi-transparent background.
/// Useful for blocking user interaction during async operations.
///
/// Example usage:
/// ```dart
/// Stack(
///   children: [
///     YourContent(),
///     if (isLoading) const LoadingOverlay(),
///   ],
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Creates a LoadingOverlay.
  const LoadingOverlay({
    this.message,
    this.backgroundColor,
    this.indicatorColor,
    super.key,
  });

  /// Optional message displayed below the indicator
  final String? message;

  /// Custom background color for the overlay
  /// If null, uses semi-transparent black
  final Color? backgroundColor;

  /// Custom color for the loading indicator
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.3),
      child: LoadingIndicator(
        size: LoadingIndicatorSize.large,
        message: message,
        color: indicatorColor,
      ),
    );
  }
}

/// A loading indicator with a determinate progress value.
///
/// Displays progress as a percentage (0.0 to 1.0) with optional text.
///
/// Example usage:
/// ```dart
/// ProgressLoadingIndicator(
///   progress: 0.65,
///   showPercentage: true,
/// )
/// ```
class ProgressLoadingIndicator extends StatelessWidget {
  /// Creates a ProgressLoadingIndicator.
  const ProgressLoadingIndicator({
    required this.progress,
    this.size = LoadingIndicatorSize.medium,
    this.message,
    this.showPercentage = false,
    this.color,
    this.backgroundColor,
    super.key,
  });

  /// The progress value (0.0 to 1.0)
  final double progress;

  /// The size variant of the indicator
  final LoadingIndicatorSize size;

  /// Optional message displayed below the indicator
  final String? message;

  /// Whether to show the percentage value
  final bool showPercentage;

  /// Custom color for the progress indicator
  final Color? color;

  /// Custom background color for the track
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final indicatorSize = _getIndicatorSize();
    final strokeWidth = _getStrokeWidth();
    final effectiveColor = color ?? colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainerHighest;

    Widget indicator = SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        backgroundColor: effectiveBackgroundColor,
      ),
    );

    // Wrap with percentage text if needed
    if (showPercentage) {
      indicator = Stack(
        alignment: Alignment.center,
        children: [
          indicator,
          Text(
            '${(progress * 100).toInt()}%',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // Add message if provided
    if (message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Center(child: indicator);
  }

  double _getIndicatorSize() {
    switch (size) {
      case LoadingIndicatorSize.small:
        return 24.0;
      case LoadingIndicatorSize.medium:
        return 48.0;
      case LoadingIndicatorSize.large:
        return 72.0;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingIndicatorSize.small:
        return 3.0;
      case LoadingIndicatorSize.medium:
        return 4.0;
      case LoadingIndicatorSize.large:
        return 6.0;
    }
  }
}
