import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/health_provider.dart';

/// A dialog widget that explains why health data access is needed
/// and allows the user to grant or deny permissions.
///
/// This dialog shows:
/// - An icon and title explaining the purpose
/// - A description of why health access is beneficial
/// - A list of data that will be accessed
/// - "Allow Access" button to request permissions
/// - "Not Now" button to dismiss without granting
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => const HealthPermissionDialog(),
/// );
/// ```
class HealthPermissionDialog extends StatefulWidget {
  /// Creates a HealthPermissionDialog.
  const HealthPermissionDialog({super.key});

  /// Shows the health permission dialog.
  ///
  /// Returns a [Future] that completes with `true` if permissions were granted,
  /// `false` if denied, or `null` if dismissed without action.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const HealthPermissionDialog(),
    );
  }

  @override
  State<HealthPermissionDialog> createState() => _HealthPermissionDialogState();
}

class _HealthPermissionDialogState extends State<HealthPermissionDialog> {
  bool _isLoading = false;
  String? _resultMessage;
  bool? _permissionResult;

  Future<void> _handleAllowAccess() async {
    setState(() {
      _isLoading = true;
      _resultMessage = null;
      _permissionResult = null;
    });

    AppLogger.info('User tapped Allow Access for health permissions');

    try {
      final healthProvider = context.read<HealthProvider>();
      final granted = await healthProvider.requestPermissions();

      setState(() {
        _isLoading = false;
        _permissionResult = granted;
        _resultMessage = granted
            ? 'Health access granted! You can now sync your steps.'
            : 'Health access was denied. You can enable it later in settings.';
      });

      AppLogger.info('Health permission request result: ${granted ? 'granted' : 'denied'}');

      // Auto-close after showing result
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pop(granted);
      }
    } catch (e) {
      AppLogger.error('Error requesting health permissions', e);
      setState(() {
        _isLoading = false;
        _resultMessage = 'An error occurred. Please try again.';
        _permissionResult = false;
      });
    }
  }

  void _handleNotNow() {
    AppLogger.info('User tapped Not Now for health permissions');
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      contentPadding: const EdgeInsets.all(24.0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Connect Health Data',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Allow access to your health data to automatically track your daily steps. '
              'This provides more accurate step counting using your device\'s sensors.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Data access list
            _buildDataAccessList(theme, colorScheme),
            const SizedBox(height: 24),

            // Result message (if any)
            if (_resultMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _permissionResult == true
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _permissionResult == true
                          ? Icons.check_circle_rounded
                          : Icons.info_rounded,
                      size: 20,
                      color: _permissionResult == true
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _resultMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _permissionResult == true
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Buttons
            if (!_isLoading && _permissionResult == null) ...[
              AppButton(
                label: 'Allow Access',
                onPressed: _handleAllowAccess,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                fullWidth: true,
                icon: Icons.check_rounded,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Not Now',
                onPressed: _handleNotNow,
                variant: AppButtonVariant.text,
                size: AppButtonSize.medium,
              ),
            ],

            // Loading indicator
            if (_isLoading)
              Column(
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Requesting permissions...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataAccessList(ThemeData theme, ColorScheme colorScheme) {
    final items = [
      ('Step count', Icons.directions_walk_rounded),
      ('Activity data', Icons.fitness_center_rounded),
      ('Distance walked', Icons.straighten_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We will access:',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      item.$2,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.$1,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
