/// Error widget for displaying error states in the application.
///
/// This widget provides a consistent error display with icon, title,
/// message, and optional retry functionality.
library;

import 'package:flutter/material.dart';

/// A widget that displays an error state with optional retry action.
///
/// Shows an error icon, title, message, and optional retry button
/// using the theme's error colors for consistency.
///
/// Example usage:
/// ```dart
/// // Basic error display
/// AppErrorWidget(message: 'Failed to load data')
///
/// // With retry action
/// AppErrorWidget(
///   message: 'Network error occurred',
///   onRetry: () => fetchData(),
/// )
///
/// // Custom title and icon
/// AppErrorWidget(
///   title: 'Connection Lost',
///   message: 'Please check your internet connection',
///   icon: Icons.wifi_off,
///   onRetry: () => reconnect(),
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  /// Creates an error display widget.
  ///
  /// The [message] parameter is required and describes the error.
  /// The [title] defaults to 'Something went wrong'.
  /// The [icon] defaults to [Icons.error_outline].
  /// When [onRetry] is provided, a retry button is displayed.
  const AppErrorWidget({
    required this.message,
    super.key,
    this.title = 'Something went wrong',
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// The error message describing what went wrong.
  ///
  /// This is displayed below the title with secondary styling.
  final String message;

  /// The title displayed above the error message.
  ///
  /// Defaults to 'Something went wrong'.
  final String title;

  /// Callback function invoked when the retry button is pressed.
  ///
  /// When null, the retry button is not displayed.
  final VoidCallback? onRetry;

  /// The icon displayed above the title.
  ///
  /// Defaults to [Icons.error_outline].
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),

            // Error title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Error message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
