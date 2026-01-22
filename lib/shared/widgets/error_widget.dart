import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'app_button.dart';

/// A reusable error display widget following Material Design 3 guidelines.
///
/// Displays an error message with an optional icon and retry button.
/// Useful for showing error states in lists, pages, or data loading failures.
///
/// Example usage:
/// ```dart
/// AppErrorWidget(
///   message: 'Failed to load data',
///   onRetry: () => refreshData(),
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  /// Creates an AppErrorWidget.
  ///
  /// The [message] parameter is required and describes the error.
  const AppErrorWidget({
    required this.message,
    this.title,
    this.icon,
    this.iconColor,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.compact = false,
    super.key,
  });

  /// The main error message to display
  final String message;

  /// Optional title displayed above the message
  final String? title;

  /// Custom icon to display
  /// If null, uses default error icon
  final IconData? icon;

  /// Custom color for the icon
  /// If null, uses theme error color
  final Color? iconColor;

  /// Callback when the retry button is pressed
  /// If null, no retry button is shown
  final VoidCallback? onRetry;

  /// Custom label for the retry button
  final String retryLabel;

  /// Whether to use a compact layout
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final effectiveIcon = icon ?? Icons.error_outline_rounded;
    final effectiveIconColor = iconColor ?? colorScheme.error;

    if (compact) {
      return _buildCompactLayout(
        context,
        colorScheme,
        textTheme,
        effectiveIcon,
        effectiveIconColor,
      );
    }

    return _buildFullLayout(
      context,
      colorScheme,
      textTheme,
      effectiveIcon,
      effectiveIconColor,
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    IconData effectiveIcon,
    Color effectiveIconColor,
  ) {
    return Padding(
      padding: AppSpacing.allMd,
      child: Row(
        children: [
          Icon(
            effectiveIcon,
            color: effectiveIconColor,
            size: AppSpacing.iconMd,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
        ],
      ),
    );
  }

  Widget _buildFullLayout(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    IconData effectiveIcon,
    Color effectiveIconColor,
  ) {
    return Center(
      child: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                effectiveIcon,
                color: effectiveIconColor,
                size: 40,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Title if provided
            if (title != null) ...[
              Text(
                title!,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
            ],

            // Error message
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button if provided
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.lg),
              AppButton(
                label: retryLabel,
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A more prominent error display for critical errors.
///
/// Similar to AppErrorWidget but with a more attention-grabbing design.
class CriticalErrorWidget extends StatelessWidget {
  /// Creates a CriticalErrorWidget.
  const CriticalErrorWidget({
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.showContactSupport = false,
    this.onContactSupport,
    super.key,
  });

  /// The main error message to display
  final String message;

  /// Title displayed above the message
  final String title;

  /// Callback when the retry button is pressed
  final VoidCallback? onRetry;

  /// Custom label for the retry button
  final String retryLabel;

  /// Whether to show a contact support option
  final bool showContactSupport;

  /// Callback when contact support is pressed
  final VoidCallback? onContactSupport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: AppSpacing.allXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large error icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.onErrorContainer,
                size: 64,
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),

            // Error message
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSpacing.xl),

            // Action buttons
            if (onRetry != null)
              AppButton(
                label: retryLabel,
                onPressed: onRetry,
                variant: AppButtonVariant.primary,
                icon: Icons.refresh_rounded,
                fullWidth: true,
              ),

            if (showContactSupport && onContactSupport != null) ...[
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Contact Support',
                onPressed: onContactSupport,
                variant: AppButtonVariant.text,
                icon: Icons.support_agent_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An inline error message widget for form validation.
///
/// Displays a compact error message with an icon.
class InlineError extends StatelessWidget {
  /// Creates an InlineError.
  const InlineError({
    required this.message,
    this.icon,
    super.key,
  });

  /// The error message to display
  final String message;

  /// Custom icon to display
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: colorScheme.error,
            size: AppSpacing.iconSm,
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
