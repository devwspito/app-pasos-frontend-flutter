/// Hourly peak chart widget using fl_chart.
///
/// Displays step counts as a bar chart showing hourly distribution.
/// Data is passed via constructor - no BlocBuilder inside this widget.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/hourly_peak.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A bar chart widget that displays hourly step distribution.
///
/// Shows up to 24 bars representing steps for each hour of the day.
/// Bars are colored by intensity based on step count.
///
/// Example usage:
/// ```dart
/// HourlyChart(
///   peaks: [
///     HourlyPeak(hour: 8, total: 1200),
///     HourlyPeak(hour: 12, total: 800),
///     // ...
///   ],
/// )
/// ```
class HourlyChart extends StatelessWidget {
  /// Creates an [HourlyChart].
  ///
  /// [peaks] - List of hourly peak data points to display.
  const HourlyChart({
    required this.peaks,
    super.key,
  });

  /// The hourly peak data to display on the chart.
  final List<HourlyPeak> peaks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle empty state
    if (peaks.isEmpty) {
      return _buildEmptyState(theme);
    }

    // Calculate max Y value for proper scaling
    final maxY = _calculateMaxY();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              gridData: _buildGridData(colorScheme),
              titlesData: _buildTitlesData(theme, colorScheme, maxY),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(colorScheme),
              barTouchData: _buildBarTouchData(theme, colorScheme),
            ),
          ),
        );
      },
    );
  }

  /// Builds the empty state widget when no data is available.
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No data yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start walking to see your hourly activity',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculates the maximum Y value with padding for better visualization.
  double _calculateMaxY() {
    if (peaks.isEmpty) return 1000;
    final maxTotal = peaks.map((p) => p.total).reduce(
          (a, b) => a > b ? a : b,
        );
    if (maxTotal == 0) return 1000;
    // Add 20% padding to the top
    return (maxTotal * 1.2).ceilToDouble();
  }

  /// Builds the grid configuration.
  FlGridData _buildGridData(ColorScheme colorScheme) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _calculateMaxY() / 5,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          strokeWidth: 1,
        );
      },
    );
  }

  /// Builds the axis titles configuration.
  FlTitlesData _buildTitlesData(
    ThemeData theme,
    ColorScheme colorScheme,
    double maxY,
  ) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) =>
              _buildBottomTitle(value, theme, colorScheme),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          interval: maxY / 5,
          getTitlesWidget: (value, meta) =>
              _buildLeftTitle(value, theme, colorScheme),
        ),
      ),
    );
  }

  /// Builds a single bottom axis title (hour label).
  Widget _buildBottomTitle(
    double value,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final hour = value.toInt();

    // Only show labels for every 4 hours to avoid crowding
    if (hour % 4 != 0 && hour != 23) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _formatHour(hour),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
      ),
    );
  }

  /// Builds a single left axis title (step count).
  Widget _buildLeftTitle(
    double value,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Text(
      _formatStepCount(value.toInt()),
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: 10,
      ),
    );
  }

  /// Builds the bar groups for the chart.
  List<BarChartGroupData> _buildBarGroups(ColorScheme colorScheme) {
    // Create a map for quick lookup of peak data by hour
    final peakMap = <int, int>{};
    for (final peak in peaks) {
      peakMap[peak.hour] = peak.total;
    }

    // Find max for color intensity calculation
    final maxTotal = _calculateMaxValue();

    // Build bars for all 24 hours
    return List.generate(24, (hour) {
      final total = peakMap[hour] ?? 0;
      final intensity = maxTotal > 0 ? total / maxTotal : 0.0;

      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: total.toDouble(),
            color: _getBarColor(intensity, colorScheme),
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  /// Calculates the maximum value for intensity calculation.
  int _calculateMaxValue() {
    if (peaks.isEmpty) return 0;
    return peaks.map((p) => p.total).reduce((a, b) => a > b ? a : b);
  }

  /// Gets the bar color based on intensity (0.0 to 1.0).
  Color _getBarColor(double intensity, ColorScheme colorScheme) {
    if (intensity <= 0) {
      return colorScheme.outlineVariant.withOpacity(0.3);
    } else if (intensity < 0.25) {
      return colorScheme.primary.withOpacity(0.4);
    } else if (intensity < 0.5) {
      return colorScheme.primary.withOpacity(0.6);
    } else if (intensity < 0.75) {
      return colorScheme.primary.withOpacity(0.8);
    } else {
      return colorScheme.primary;
    }
  }

  /// Builds the touch interaction configuration.
  BarTouchData _buildBarTouchData(ThemeData theme, ColorScheme colorScheme) {
    // Create a map for quick lookup of peak data by hour
    final peakMap = <int, int>{};
    for (final peak in peaks) {
      peakMap[peak.hour] = peak.total;
    }

    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        getTooltipColor: (_) => colorScheme.inverseSurface,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final hour = group.x;
          final total = peakMap[hour] ?? 0;

          return BarTooltipItem(
            '${_formatHourFull(hour)}\n',
            theme.textTheme.bodySmall!.copyWith(
              color: colorScheme.onInverseSurface,
              fontSize: 11,
            ),
            children: [
              TextSpan(
                text: '${_formatNumber(total)} steps',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Formats hour for compact display (e.g., "0", "12", "23").
  String _formatHour(int hour) {
    if (hour == 0) return '12a';
    if (hour == 12) return '12p';
    if (hour < 12) return '${hour}a';
    return '${hour - 12}p';
  }

  /// Formats hour for full display in tooltip (e.g., "2:00 PM").
  String _formatHourFull(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour == 12) return '12:00 PM';
    if (hour < 12) return '$hour:00 AM';
    return '${hour - 12}:00 PM';
  }

  /// Formats a number with commas for readability.
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    final str = number.toString();
    final result = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(str[i]);
    }
    return result.toString();
  }

  /// Formats step count in a compact form (e.g., 1.5K).
  String _formatStepCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 10000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
  }
}
