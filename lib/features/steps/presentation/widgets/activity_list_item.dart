import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/step_record.dart';

/// A list tile widget displaying a single step activity record.
///
/// Shows step count, recorded time, and source with an appropriate icon.
///
/// Example:
/// ```dart
/// ActivityListItem(
///   record: stepRecord,
///   onTap: () => showDetails(stepRecord),
/// )
/// ```
class ActivityListItem extends StatelessWidget {
  /// Creates an [ActivityListItem].
  ///
  /// [record] is the step record to display.
  const ActivityListItem({
    required this.record,
    this.onTap,
    this.showDate = false,
    this.dense = false,
    super.key,
  });

  /// The step record to display.
  final StepRecord record;

  /// Callback when the item is tapped.
  final VoidCallback? onTap;

  /// Whether to show the full date or just the time.
  final bool showDate;

  /// Whether to use a dense layout.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      dense: dense,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: _buildSourceIcon(colorScheme),
      title: _buildTitle(theme),
      subtitle: _buildSubtitle(theme),
      trailing: _buildTrailing(theme),
    );
  }

  Widget _buildSourceIcon(ColorScheme colorScheme) {
    final iconData = _getSourceIcon();
    final backgroundColor = _getSourceColor(colorScheme).withOpacity(0.1);
    final iconColor = _getSourceColor(colorScheme);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: AppSpacing.iconMd,
      ),
    );
  }

  IconData _getSourceIcon() {
    switch (record.source) {
      case StepSource.manual:
        return Icons.edit_rounded;
      case StepSource.healthkit:
        return Icons.favorite_rounded;
      case StepSource.googlefit:
        return Icons.fitness_center_rounded;
    }
  }

  Color _getSourceColor(ColorScheme colorScheme) {
    switch (record.source) {
      case StepSource.manual:
        return colorScheme.secondary;
      case StepSource.healthkit:
        return Colors.red;
      case StepSource.googlefit:
        return Colors.green;
    }
  }

  String _getSourceLabel() {
    switch (record.source) {
      case StepSource.manual:
        return 'Manual Entry';
      case StepSource.healthkit:
        return 'Apple Health';
      case StepSource.googlefit:
        return 'Google Fit';
    }
  }

  Widget _buildTitle(ThemeData theme) {
    final formatter = NumberFormat.decimalPattern();
    final formattedSteps = formatter.format(record.stepCount);

    return Text(
      '$formattedSteps steps',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    final timeFormat = DateFormat.jm();
    final dateFormat = DateFormat.MMMd();

    final timeString = timeFormat.format(record.recordedAt);
    final dateString = showDate
        ? '${dateFormat.format(record.recordedAt)} at $timeString'
        : timeString;

    return Row(
      children: [
        Text(
          _getSourceLabel(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          dateString,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing(ThemeData theme) {
    if (onTap == null) {
      return const SizedBox.shrink();
    }

    return Icon(
      Icons.chevron_right_rounded,
      color: theme.colorScheme.outline,
      size: AppSpacing.iconMd,
    );
  }
}

/// A widget displaying a list of activity items with optional header.
///
/// Example:
/// ```dart
/// ActivityList(
///   records: stepsState.hourlyData,
///   onItemTap: (record) => showDetails(record),
/// )
/// ```
class ActivityList extends StatelessWidget {
  /// Creates an [ActivityList].
  const ActivityList({
    required this.records,
    this.onItemTap,
    this.header,
    this.emptyMessage = 'No activities recorded',
    this.showDates = false,
    this.maxItems,
    super.key,
  });

  /// The list of step records to display.
  final List<StepRecord> records;

  /// Callback when an item is tapped.
  final ValueChanged<StepRecord>? onItemTap;

  /// Optional header widget above the list.
  final Widget? header;

  /// Message to show when the list is empty.
  final String emptyMessage;

  /// Whether to show dates on items.
  final bool showDates;

  /// Maximum number of items to show. If null, shows all.
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (records.isEmpty) {
      return _buildEmptyState(theme);
    }

    final displayRecords = maxItems != null
        ? records.take(maxItems!).toList()
        : records;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) header!,
        ...displayRecords.map((record) => ActivityListItem(
              record: record,
              onTap: onItemTap != null ? () => onItemTap!(record) : null,
              showDate: showDates,
            )),
        if (maxItems != null && records.length > maxItems!)
          _buildShowMoreButton(theme, records.length - maxItems!),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: AppSpacing.allMd,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_walk_rounded,
              size: AppSpacing.xxl,
              color: theme.colorScheme.outline,
            ),
            AppSpacing.gapVerticalSm,
            Text(
              emptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowMoreButton(ThemeData theme, int remainingCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        child: Text(
          '+$remainingCount more activities',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
