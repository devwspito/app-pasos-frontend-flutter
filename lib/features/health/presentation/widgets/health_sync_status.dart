import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/health_provider.dart';

/// A widget that displays the current health sync status.
///
/// Shows:
/// - Last sync time (e.g., "Last synced: 5 minutes ago")
/// - Synced step count
/// - Sync button to trigger manual sync
/// - Loading indicator during sync
/// - Error state with retry button
///
/// This widget listens to [HealthProvider] and updates automatically
/// when the sync status changes.
///
/// Usage:
/// ```dart
/// HealthSyncStatus(
///   onSyncComplete: (steps) {
///     print('Synced $steps steps');
///   },
/// )
/// ```
class HealthSyncStatus extends StatelessWidget {
  /// Creates a HealthSyncStatus widget.
  const HealthSyncStatus({
    super.key,
    this.onSyncComplete,
    this.onPermissionRequired,
  });

  /// Callback invoked when sync completes successfully.
  ///
  /// [steps] is the number of steps synced from health data.
  final void Function(int steps)? onSyncComplete;

  /// Callback invoked when permissions are required to sync.
  ///
  /// Use this to show the permission dialog.
  final VoidCallback? onPermissionRequired;

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, healthProvider),
              const SizedBox(height: 16),
              _buildContent(context, healthProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, HealthProvider healthProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(healthProvider, colorScheme).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getStatusIcon(healthProvider),
            size: 22,
            color: _getStatusColor(healthProvider, colorScheme),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Data Sync',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getStatusText(healthProvider),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getStatusTextColor(healthProvider, colorScheme),
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(context, healthProvider),
      ],
    );
  }

  Widget _buildContent(BuildContext context, HealthProvider healthProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Error state
    if (healthProvider.hasError) {
      return _buildErrorContent(context, healthProvider);
    }

    // Permission denied state
    if (healthProvider.isPermissionDenied) {
      return _buildPermissionDeniedContent(context, healthProvider);
    }

    // Syncing state
    if (healthProvider.isSyncing) {
      return _buildSyncingContent(context);
    }

    // Synced or initial state
    return Column(
      children: [
        // Step count display
        if (healthProvider.hasSyncedData) ...[
          _buildStepCountDisplay(context, healthProvider),
          const SizedBox(height: 16),
        ],

        // Last sync time
        if (healthProvider.hasSyncedData) ...[
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Last synced: ${healthProvider.lastSyncTimeFormatted}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Sync button
        _buildSyncButton(context, healthProvider),
      ],
    );
  }

  Widget _buildStepCountDisplay(BuildContext context, HealthProvider healthProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.directions_walk_rounded,
                size: 28,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatStepCount(healthProvider.syncedSteps),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'steps',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'from health data today',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncingContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Syncing steps from health data...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, HealthProvider healthProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            healthProvider.errorMessage ?? 'An error occurred',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Retry',
            onPressed: () => _handleSync(context, healthProvider),
            variant: AppButtonVariant.primary,
            size: AppButtonSize.medium,
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedContent(BuildContext context, HealthProvider healthProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 40,
            color: colorScheme.tertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'Health access is required',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onTertiaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Grant permission to sync your step data from your device\'s health app.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Grant Permission',
            onPressed: () => _handleRequestPermission(context, healthProvider),
            variant: AppButtonVariant.primary,
            size: AppButtonSize.medium,
            icon: Icons.health_and_safety_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context, HealthProvider healthProvider) {
    final isSynced = healthProvider.status == HealthStatus.synced;

    return AppButton(
      label: healthProvider.hasSyncedData ? 'Sync Again' : 'Sync Now',
      onPressed: healthProvider.permissionGranted
          ? () => _handleSync(context, healthProvider)
          : () => _handleRequestPermission(context, healthProvider),
      variant: isSynced ? AppButtonVariant.outline : AppButtonVariant.primary,
      size: AppButtonSize.medium,
      fullWidth: true,
      icon: Icons.sync_rounded,
    );
  }

  Widget _buildStatusBadge(BuildContext context, HealthProvider healthProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!healthProvider.permissionGranted || healthProvider.hasError) {
      return const SizedBox.shrink();
    }

    final isSynced = healthProvider.status == HealthStatus.synced;
    final isSyncing = healthProvider.isSyncing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced
            ? colorScheme.primaryContainer
            : isSyncing
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isSynced
            ? 'Synced'
            : isSyncing
                ? 'Syncing'
                : 'Ready',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isSynced
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  IconData _getStatusIcon(HealthProvider healthProvider) {
    if (healthProvider.hasError) return Icons.error_outline_rounded;
    if (healthProvider.isPermissionDenied) return Icons.lock_outline_rounded;
    if (healthProvider.isSyncing) return Icons.sync_rounded;
    if (healthProvider.status == HealthStatus.synced) return Icons.check_circle_rounded;
    return Icons.favorite_rounded;
  }

  Color _getStatusColor(HealthProvider healthProvider, ColorScheme colorScheme) {
    if (healthProvider.hasError) return colorScheme.error;
    if (healthProvider.isPermissionDenied) return colorScheme.tertiary;
    if (healthProvider.status == HealthStatus.synced) return colorScheme.primary;
    return colorScheme.primary;
  }

  String _getStatusText(HealthProvider healthProvider) {
    if (healthProvider.hasError) return 'Sync failed';
    if (healthProvider.isPermissionDenied) return 'Permission required';
    if (healthProvider.isSyncing) return 'Syncing...';
    if (healthProvider.status == HealthStatus.synced) return 'Connected';
    return 'Ready to sync';
  }

  Color _getStatusTextColor(HealthProvider healthProvider, ColorScheme colorScheme) {
    if (healthProvider.hasError) return colorScheme.error;
    if (healthProvider.isPermissionDenied) return colorScheme.tertiary;
    return colorScheme.onSurfaceVariant;
  }

  String _formatStepCount(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  Future<void> _handleSync(BuildContext context, HealthProvider healthProvider) async {
    AppLogger.info('Manual sync triggered');

    await healthProvider.syncTodaySteps();

    if (healthProvider.status == HealthStatus.synced) {
      onSyncComplete?.call(healthProvider.syncedSteps);
    }
  }

  Future<void> _handleRequestPermission(BuildContext context, HealthProvider healthProvider) async {
    AppLogger.info('Permission request triggered from sync status');

    // If callback provided, use it (allows parent to show dialog)
    if (onPermissionRequired != null) {
      onPermissionRequired!();
      return;
    }

    // Otherwise, request directly
    final granted = await healthProvider.requestPermissions();
    if (granted) {
      await healthProvider.syncTodaySteps();
      if (healthProvider.status == HealthStatus.synced) {
        onSyncComplete?.call(healthProvider.syncedSteps);
      }
    }
  }
}
