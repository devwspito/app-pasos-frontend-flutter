/// Stats overview card widget for displaying step statistics.
///
/// This widget shows a row of statistics for different time periods:
/// Today, Week, Month, and All-Time.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_stats.dart';
import 'package:app_pasos_frontend/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// A card widget that displays step statistics for different time periods.
///
/// Shows a horizontal row of 4 stat items:
/// - Today: Steps recorded today
/// - Week: Steps recorded this week
/// - Month: Steps recorded this month
/// - All-Time: Total steps recorded ever
///
/// Example usage:
/// ```dart
/// StatsOverviewCard(
///   stats: StepStats(
///     today: 5000,
///     week: 35000,
///     month: 150000,
///     allTime: 1500000,
///   ),
/// )
/// ```
class StatsOverviewCard extends StatelessWidget {
  /// Creates a [StatsOverviewCard].
  ///
  /// [stats] - The step statistics to display.
  const StatsOverviewCard({
    required this.stats,
    super.key,
  });

  /// The step statistics to display.
  final StepStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Today',
                  value: stats.today,
                  icon: Icons.today,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Week',
                  value: stats.week,
                  icon: Icons.date_range,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Month',
                  value: stats.month,
                  icon: Icons.calendar_month,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'All-Time',
                  value: stats.allTime,
                  icon: Icons.all_inclusive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single stat item widget showing label and value.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  /// The label for this stat (e.g., "Today", "Week").
  final String label;

  /// The numeric value to display.
  final int value;

  /// The icon to display above the value.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),

        // Value
        Text(
          _formatCompactNumber(value),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),

        // Label
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Formats a number in a compact form (e.g., 1.5K, 2.3M).
  String _formatCompactNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 10000) {
      final value = number / 1000;
      return '${value.toStringAsFixed(1)}K';
    } else if (number < 1000000) {
      final value = number / 1000;
      return '${value.toStringAsFixed(0)}K';
    } else {
      final value = number / 1000000;
      return '${value.toStringAsFixed(1)}M';
    }
  }
}
