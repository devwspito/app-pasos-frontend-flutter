import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A reusable error display widget that provides consistent styling
/// across the app with Material 3 design.
///
/// Features:
/// - Error icon and message display
/// - Optional retry button with callback
/// - Configurable icon, colors, and sizes
/// - Centered layout suitable for full-screen or inline use
///
/// Usage:
/// ```dart
/// AppError(
///   message: 'Failed to load data',
/// )
/// ```
///
/// With retry button:
/// ```dart
/// AppError(
///   message: 'Network error occurred',
///   onRetry: () => fetchData(),
///   retryLabel: 'Try Again',
/// )
/// ```
///
/// Custom icon:
/// ```dart
/// AppError(
///   icon: Icons.cloud_off,
///   message: 'No internet connection',
///   onRetry: () => checkConnection(),
/// )
/// ```
class AppError extends StatelessWidget {
  /// Creates an [AppError] widget.
  ///
  /// The [message] parameter is required.
  const AppError({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.onRetry,
    this.retryLabel,
    this.padding,
  });

  /// The error message to display.
  final String message;

  /// Optional title displayed above the message.
  final String? title;

  /// The icon to display.
  /// Defaults to [Icons.error_outline].
  final IconData? icon;

  /// The size of the error icon.
  /// When null, defaults to 48.0.
  final double? iconSize;

  /// The color of the error icon.
  /// When null, uses the theme's error color.
  final Color? iconColor;

  /// Callback when the retry button is pressed.
  /// When null, no retry button is displayed.
  final VoidCallback? onRetry;

  /// The label for the retry button.
  /// Defaults to 'Retry'.
  final String? retryLabel;

  /// The padding around the error widget.
  /// When null, uses [AppSpacing.lg].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.lg);
    final effectiveIconColor = iconColor ?? colorScheme.error;
    final effectiveIconSize = iconSize ?? 48.0;

    return Padding(
      padding: effectivePadding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: effectiveIconSize,
              color: effectiveIconColor,
            ),
            const SizedBox(height: AppSpacing.md),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(
                onPressed: onRetry,
                child: Text(retryLabel ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact error display suitable for inline use within forms or lists.
///
/// Usage:
/// ```dart
/// AppErrorInline(
///   message: 'Invalid input',
/// )
/// ```
class AppErrorInline extends StatelessWidget {
  /// Creates an [AppErrorInline] widget.
  const AppErrorInline({
    super.key,
    required this.message,
    this.icon,
    this.iconSize,
    this.textStyle,
    this.padding,
  });

  /// The error message to display.
  final String message;

  /// The icon to display.
  /// Defaults to [Icons.error_outline].
  final IconData? icon;

  /// The size of the error icon.
  /// Defaults to 16.0.
  final double? iconSize;

  /// Custom text style for the message.
  /// When null, uses bodySmall with error color.
  final TextStyle? textStyle;

  /// The padding around the error widget.
  /// When null, uses symmetric vertical padding of [AppSpacing.xs].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveIconSize = iconSize ?? 16.0;
    final effectiveTextStyle = textStyle ?? theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.error,
    );

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: effectiveIconSize,
            color: colorScheme.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              message,
              style: effectiveTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

/// A banner-style error display that spans the full width.
///
/// Usage:
/// ```dart
/// AppErrorBanner(
///   message: 'Connection lost',
///   onRetry: () => reconnect(),
/// )
/// ```
class AppErrorBanner extends StatelessWidget {
  /// Creates an [AppErrorBanner] widget.
  const AppErrorBanner({
    super.key,
    required this.message,
    this.icon,
    this.onRetry,
    this.onDismiss,
    this.retryLabel,
    this.dismissLabel,
    this.backgroundColor,
  });

  /// The error message to display.
  final String message;

  /// The icon to display.
  /// Defaults to [Icons.error_outline].
  final IconData? icon;

  /// Callback when the retry button is pressed.
  final VoidCallback? onRetry;

  /// Callback when the dismiss button is pressed.
  final VoidCallback? onDismiss;

  /// The label for the retry button.
  /// Defaults to 'Retry'.
  final String? retryLabel;

  /// The label for the dismiss button.
  /// Defaults to 'Dismiss'.
  final String? dismissLabel;

  /// The background color of the banner.
  /// When null, uses the theme's error container color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.errorContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: effectiveBackgroundColor,
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: colorScheme.onErrorContainer,
            size: 24.0,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                retryLabel ?? 'Retry',
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(
                Icons.close,
                color: colorScheme.onErrorContainer,
              ),
              onPressed: onDismiss,
              tooltip: dismissLabel ?? 'Dismiss',
            ),
        ],
      ),
    );
  }
}
