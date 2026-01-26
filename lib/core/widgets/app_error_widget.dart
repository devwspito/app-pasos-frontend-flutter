import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

/// A widget that displays an error state with optional retry functionality.
///
/// Use this widget to show error messages with a consistent design
/// throughout the application. It supports customizable icons, titles,
/// and retry actions.
///
/// Example:
/// ```dart
/// // Basic error widget
/// AppErrorWidget(message: 'Failed to load data')
///
/// // Error widget with retry
/// AppErrorWidget(
///   title: 'Connection Error',
///   message: 'Please check your internet connection',
///   onRetry: () => loadData(),
/// )
///
/// // Custom icon error
/// AppErrorWidget(
///   icon: Icons.cloud_off,
///   message: 'Server is unavailable',
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  /// Creates an error widget with the specified parameters.
  ///
  /// [message] is required and describes the error.
  /// [onRetry] callback is invoked when the retry button is pressed.
  /// [icon] overrides the default error icon.
  /// [title] overrides the default title.
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.title,
  });

  /// The error message to display.
  final String message;

  /// Callback invoked when the retry button is pressed.
  ///
  /// If null, the retry button is not shown.
  final VoidCallback? onRetry;

  /// The icon to display above the title.
  ///
  /// Defaults to [Icons.error_outline] with error color.
  final IconData? icon;

  /// The title text above the error message.
  ///
  /// Defaults to 'Something went wrong'.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64.0,
              color: errorColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title ?? 'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Try Again',
                onPressed: onRetry,
                icon: Icons.refresh,
                variant: AppButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
