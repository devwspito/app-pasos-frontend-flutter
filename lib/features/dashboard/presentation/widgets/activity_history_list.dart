/// Activity history list widget for displaying recent step records.
///
/// This widget shows a list of recent activity entries with step counts,
/// sources, and timestamps. Used in the DashboardPage to show recent activity.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';
import 'package:flutter/material.dart';

/// A widget that displays a list of recent step activity records.
///
/// Shows the last 10 activity items with:
/// - Icon indicating the step source
/// - Step count
/// - Source badge (native, manual, web)
/// - Timestamp
///
/// Example usage:
/// ```dart
/// ActivityHistoryList(
///   records: stepRecords,
/// )
/// ```
class ActivityHistoryList extends StatelessWidget {
  /// Creates an [ActivityHistoryList] widget.
  ///
  /// [records] - The list of step records to display.
  /// [maxItems] - Maximum number of items to show (default: 10).
  const ActivityHistoryList({
    required this.records,
    super.key,
    this.maxItems = 10,
  });

  /// The list of step records to display.
  final List<StepRecord> records;

  /// Maximum number of items to show.
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Limit to maxItems and sort by timestamp (most recent first)
    final displayRecords = _getDisplayRecords();

    if (displayRecords.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${displayRecords.length} items',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayRecords.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _ActivityItem(record: displayRecords[index]);
            },
          ),
        ],
      ),
    );
  }

  /// Gets the records to display, sorted and limited.
  List<StepRecord> _getDisplayRecords() {
    if (records.isEmpty) return [];

    // Sort by timestamp (most recent first)
    final sorted = List<StepRecord>.from(records)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Limit to maxItems
    return sorted.take(maxItems).toList();
  }

  /// Builds the empty state when no records exist.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No Activity Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your step records will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual activity item widget.
class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.record});

  final StepRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Source icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSourceColor(colorScheme).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getSourceIcon(),
              size: 20,
              color: _getSourceColor(colorScheme),
            ),
          ),
          const SizedBox(width: 12),
          // Step count and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatStepCount(record.count),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SourceBadge(source: record.source),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(record.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Arrow indicator
          Icon(
            Icons.chevron_right,
            size: 20,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  /// Gets the icon for the step source.
  IconData _getSourceIcon() {
    return switch (record.source) {
      StepSource.native => Icons.directions_walk,
      StepSource.manual => Icons.edit,
      StepSource.web => Icons.language,
    };
  }

  /// Gets the color for the step source.
  Color _getSourceColor(ColorScheme colorScheme) {
    return switch (record.source) {
      StepSource.native => colorScheme.primary,
      StepSource.manual => colorScheme.secondary,
      StepSource.web => colorScheme.tertiary,
    };
  }

  /// Formats the step count with thousands separator.
  String _formatStepCount(int count) {
    if (count < 1000) {
      return '$count steps';
    }
    // Simple thousands formatting without intl package
    final thousands = count ~/ 1000;
    final remainder = count % 1000;
    if (remainder == 0) {
      return '${thousands}k steps';
    }
    return '$thousands,${remainder.toString().padLeft(3, '0')} steps';
  }

  /// Formats the timestamp for display.
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(timestamp)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return _formatDate(timestamp);
    }
  }

  /// Formats time as HH:mm.
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats date as MMM d.
  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }
}

/// Badge widget showing the step source.
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final StepSource source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (label, color) = switch (source) {
      StepSource.native => ('Device', colorScheme.primary),
      StepSource.manual => ('Manual', colorScheme.secondary),
      StepSource.web => ('Web', colorScheme.tertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
