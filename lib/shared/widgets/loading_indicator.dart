/// Loading indicator widget for displaying loading states.
///
/// This widget provides a flexible loading indicator that can be used
/// throughout the application for consistent loading state display.
library;

import 'package:flutter/material.dart';

/// A customizable loading indicator widget.
///
/// Displays a circular progress indicator with optional message and
/// overlay mode for full-screen loading states.
///
/// Example usage:
/// ```dart
/// // Simple loading indicator
/// LoadingIndicator()
///
/// // With message
/// LoadingIndicator(message: 'Loading data...')
///
/// // Full-screen overlay
/// LoadingIndicator(overlay: true, message: 'Please wait...')
/// ```
class LoadingIndicator extends StatelessWidget {
  /// Creates a loading indicator widget.
  ///
  /// The [size] controls the diameter of the progress indicator.
  /// The [color] overrides the theme's primary color if provided.
  /// The [message] displays optional text below the spinner.
  /// When [overlay] is true, shows a semi-transparent background.
  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.message,
    this.overlay = false,
  });

  /// The diameter of the circular progress indicator.
  ///
  /// Defaults to 40 logical pixels.
  final double size;

  /// Optional color override for the progress indicator.
  ///
  /// If null, uses the theme's primary color.
  final Color? color;

  /// Optional loading message displayed below the spinner.
  ///
  /// When provided, displays centered text below the indicator.
  final String? message;

  /// Whether to display as a full-screen overlay.
  ///
  /// When true, the indicator is displayed on a semi-transparent
  /// background that covers the entire parent widget.
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    final indicator = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: size > 30 ? 4.0 : 2.0,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (overlay) {
      return ColoredBox(
        color: theme.colorScheme.scrim.withOpacity(0.32),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: indicator,
          ),
        ),
      );
    }

    return Center(child: indicator);
  }
}
