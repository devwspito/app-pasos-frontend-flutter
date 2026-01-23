import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A reusable loading indicator widget that provides consistent styling
/// across the app with Material 3 design.
///
/// Features:
/// - Centered circular progress indicator
/// - Optional message text below the indicator
/// - Configurable size and colors
/// - Full-screen and inline variants
///
/// Usage:
/// ```dart
/// AppLoading()
/// ```
///
/// With message:
/// ```dart
/// AppLoading(
///   message: 'Loading data...',
/// )
/// ```
///
/// Custom size:
/// ```dart
/// AppLoading(
///   size: AppLoadingSize.large,
///   message: 'Please wait',
/// )
/// ```
class AppLoading extends StatelessWidget {
  /// Creates an [AppLoading] widget.
  const AppLoading({
    super.key,
    this.message,
    this.size = AppLoadingSize.medium,
    this.color,
    this.strokeWidth,
    this.padding,
  });

  /// Optional message displayed below the loading indicator.
  final String? message;

  /// The size of the loading indicator.
  /// Defaults to [AppLoadingSize.medium].
  final AppLoadingSize size;

  /// The color of the loading indicator.
  /// When null, uses the theme's primary color.
  final Color? color;

  /// The stroke width of the circular progress indicator.
  /// When null, uses a size-appropriate default.
  final double? strokeWidth;

  /// The padding around the loading widget.
  /// When null, uses [AppSpacing.md].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.md);

    return Padding(
      padding: effectivePadding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: _getIndicatorSize(),
              height: _getIndicatorSize(),
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth ?? _getStrokeWidth(),
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              ),
            ),
            if (message != null) ...[
              SizedBox(height: _getMessageSpacing()),
              Text(
                message!,
                style: _getTextStyle(theme),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _getIndicatorSize() {
    switch (size) {
      case AppLoadingSize.small:
        return 20.0;
      case AppLoadingSize.medium:
        return 36.0;
      case AppLoadingSize.large:
        return 48.0;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case AppLoadingSize.small:
        return 2.0;
      case AppLoadingSize.medium:
        return 3.0;
      case AppLoadingSize.large:
        return 4.0;
    }
  }

  double _getMessageSpacing() {
    switch (size) {
      case AppLoadingSize.small:
        return AppSpacing.xs;
      case AppLoadingSize.medium:
        return AppSpacing.sm;
      case AppLoadingSize.large:
        return AppSpacing.md;
    }
  }

  TextStyle? _getTextStyle(ThemeData theme) {
    switch (size) {
      case AppLoadingSize.small:
        return theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );
      case AppLoadingSize.medium:
        return theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );
      case AppLoadingSize.large:
        return theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );
    }
  }
}

/// Enum representing the size of the loading indicator.
enum AppLoadingSize {
  /// Small loading indicator (20x20).
  small,

  /// Medium loading indicator (36x36).
  medium,

  /// Large loading indicator (48x48).
  large,
}

/// A full-screen loading overlay that covers the entire screen.
///
/// Usage:
/// ```dart
/// AppLoadingOverlay(
///   isLoading: isDataLoading,
///   message: 'Saving changes...',
///   child: YourContent(),
/// )
/// ```
class AppLoadingOverlay extends StatelessWidget {
  /// Creates an [AppLoadingOverlay] widget.
  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.overlayColor,
    this.loadingColor,
  });

  /// The content behind the loading overlay.
  final Widget child;

  /// Whether to show the loading overlay.
  final bool isLoading;

  /// Optional message to display in the loading indicator.
  final String? message;

  /// The color of the overlay background.
  /// When null, uses a semi-transparent surface color.
  final Color? overlayColor;

  /// The color of the loading indicator.
  /// When null, uses the theme's primary color.
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? colorScheme.surface.withValues(alpha: 0.7),
              child: AppLoading(
                message: message,
                size: AppLoadingSize.large,
                color: loadingColor,
              ),
            ),
          ),
      ],
    );
  }
}

/// An inline loading indicator suitable for buttons or small spaces.
///
/// Usage:
/// ```dart
/// AppLoadingInline()
/// ```
class AppLoadingInline extends StatelessWidget {
  /// Creates an [AppLoadingInline] widget.
  const AppLoadingInline({
    super.key,
    this.size = 16.0,
    this.strokeWidth = 2.0,
    this.color,
  });

  /// The size of the loading indicator.
  /// Defaults to 16.0.
  final double size;

  /// The stroke width of the circular progress indicator.
  /// Defaults to 2.0.
  final double strokeWidth;

  /// The color of the loading indicator.
  /// When null, uses the theme's primary color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );
  }
}
