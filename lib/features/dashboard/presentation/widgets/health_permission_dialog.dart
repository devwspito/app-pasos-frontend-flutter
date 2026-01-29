/// Health permission dialog widget for requesting health data access.
///
/// This dialog explains why the app needs health data access and prompts
/// the user to grant or deny permission.
library;

import 'package:flutter/material.dart';

/// A dialog widget that requests health data permission from the user.
///
/// Shows an informative dialog explaining why the app needs access to
/// health data, with options to allow or deny the request.
///
/// Example usage:
/// ```dart
/// // Show dialog and handle result
/// final granted = await HealthPermissionDialog.show(context);
/// if (granted) {
///   // Permission granted, proceed with health data access
///   await healthService.connect();
/// } else {
///   // Permission denied, show alternative or explanation
///   showSnackBar('Health features will be limited');
/// }
/// ```
class HealthPermissionDialog extends StatelessWidget {
  /// Creates a health permission dialog.
  ///
  /// The [onAllow] callback is invoked when the user grants permission.
  /// The [onDeny] callback is invoked when the user denies permission.
  const HealthPermissionDialog({
    required this.onAllow,
    required this.onDeny,
    super.key,
  });

  /// Callback invoked when the user allows health data access.
  final VoidCallback onAllow;

  /// Callback invoked when the user denies health data access.
  final VoidCallback onDeny;

  /// Shows the health permission dialog.
  ///
  /// Returns `true` if permission was granted, `false` otherwise.
  /// The dialog cannot be dismissed by tapping outside.
  ///
  /// Example:
  /// ```dart
  /// final granted = await HealthPermissionDialog.show(context);
  /// ```
  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => HealthPermissionDialog(
            onAllow: () => Navigator.of(context).pop(true),
            onDeny: () => Navigator.of(context).pop(false),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Health icon with circular background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Connect to Health',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'App Pasos needs access to your health data to track your '
            'daily steps, calories burned, and activity progress. '
            'Your data stays private and secure on your device.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Action buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Primary action: Allow
              FilledButton(
                onPressed: onAllow,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Allow',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary action: Not Now
              OutlinedButton(
                onPressed: onDeny,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Not Now',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
