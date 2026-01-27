/// Weekly trend chart widget using fl_chart.
///
/// Displays step counts as a line chart showing trends over the week.
/// Data is passed via constructor - no BlocBuilder inside this widget.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/weekly_trend.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A line chart widget that displays weekly step trends.
///
/// Shows 7 data points connected by a line with gradient fill below.
/// Includes touch tooltips showing date and step count.
///
/// Example usage:
/// ```dart
/// WeeklyChart(
///   trends: [
///     WeeklyTrend(date: '2024-01-15', total: 8500),
///     WeeklyTrend(date: '2024-01-16', total: 9200),
///     // ...
///   ],
/// )
/// ```
class WeeklyChart extends StatelessWidget {
  /// Creates a [WeeklyChart].
  ///
  /// [trends] - List of weekly trend data points to display.
  const WeeklyChart({
    required this.trends,
    super.key,
  });

  /// The weekly trend data to display on the chart.
  final List<WeeklyTrend> trends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle empty state
    if (trends.isEmpty) {
      return _buildEmptyState(theme);
    }

    // Calculate max Y value for proper scaling
    final maxY = _calculateMaxY();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
          child: LineChart(
            LineChartData(
              gridData: _buildGridData(colorScheme),
              titlesData: _buildTitlesData(theme, colorScheme),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (trends.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                _buildLineChartBarData(colorScheme),
              ],
              lineTouchData: _buildLineTouchData(theme, colorScheme),
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
            Icons.show_chart,
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
            'Start walking to see your weekly trends',
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
    if (trends.isEmpty) return 10000;
    final maxTotal = trends.map((t) => t.total).reduce(
          (a, b) => a > b ? a : b,
        );
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
  FlTitlesData _buildTitlesData(ThemeData theme, ColorScheme colorScheme) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (value, meta) =>
              _buildBottomTitle(value, theme, colorScheme),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          interval: _calculateMaxY() / 5,
          getTitlesWidget: (value, meta) =>
              _buildLeftTitle(value, theme, colorScheme),
        ),
      ),
    );
  }

  /// Builds a single bottom axis title (day abbreviation).
  Widget _buildBottomTitle(
    double value,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final index = value.toInt();
    if (index < 0 || index >= trends.length) {
      return const SizedBox.shrink();
    }

    final trend = trends[index];
    final dayLabel = _getDayAbbreviation(trend.date);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        dayLabel,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: 11,
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

  /// Builds the main line chart bar data with gradient.
  LineChartBarData _buildLineChartBarData(ColorScheme colorScheme) {
    return LineChartBarData(
      spots: _buildSpots(),
      isCurved: true,
      curveSmoothness: 0.3,
      preventCurveOverShooting: true,
      color: colorScheme.primary,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: colorScheme.surface,
            strokeWidth: 2,
            strokeColor: colorScheme.primary,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withOpacity(0.3),
            colorScheme.primary.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  /// Builds the data points for the chart.
  List<FlSpot> _buildSpots() {
    return trends.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.total.toDouble(),
      );
    }).toList();
  }

  /// Builds the touch interaction configuration.
  LineTouchData _buildLineTouchData(ThemeData theme, ColorScheme colorScheme) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        getTooltipColor: (_) => colorScheme.inverseSurface,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final index = spot.spotIndex;
            if (index < 0 || index >= trends.length) {
              return null;
            }
            final trend = trends[index];
            return LineTooltipItem(
              '${_formatDate(trend.date)}\n',
              theme.textTheme.bodySmall!.copyWith(
                color: colorScheme.onInverseSurface,
                fontSize: 11,
              ),
              children: [
                TextSpan(
                  text: '${_formatNumber(trend.total)} steps',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
    );
  }

  /// Gets day abbreviation from date string (YYYY-MM-DD).
  String _getDayAbbreviation(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      // DateTime.weekday is 1 (Monday) to 7 (Sunday)
      return days[date.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  /// Formats a date string for display.
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    } catch (_) {
      return dateStr;
    }
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
