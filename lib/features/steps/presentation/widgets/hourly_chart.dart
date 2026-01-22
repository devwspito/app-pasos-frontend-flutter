import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/step_record.dart';

/// A line chart widget displaying hourly step breakdown.
///
/// Shows 24 hours of step data with spots for each hour.
/// Uses [LayoutBuilder] for responsive sizing.
///
/// Example:
/// ```dart
/// HourlyChart(
///   hourlyData: stepsState.hourlyData,
///   selectedDate: selectedDate,
/// )
/// ```
class HourlyChart extends StatelessWidget {
  /// Creates an [HourlyChart].
  ///
  /// [hourlyData] is the list of step records for the selected date.
  const HourlyChart({
    required this.hourlyData,
    this.lineColor,
    this.gradientColors,
    this.dotColor,
    this.backgroundColor,
    this.showDots = true,
    this.showGrid = true,
    super.key,
  });

  /// The hourly step data to display.
  final List<StepRecord> hourlyData;

  /// The color of the line.
  final Color? lineColor;

  /// Gradient colors for the area under the line.
  final List<Color>? gradientColors;

  /// The color of the data points.
  final Color? dotColor;

  /// The background color of the chart.
  final Color? backgroundColor;

  /// Whether to show dots on data points.
  final bool showDots;

  /// Whether to show grid lines.
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveLineColor = lineColor ?? colorScheme.primary;
    final effectiveGradientColors = gradientColors ??
        [
          colorScheme.primary.withOpacity(0.3),
          colorScheme.primary.withOpacity(0.0),
        ];
    final effectiveDotColor = dotColor ?? colorScheme.primary;

    if (hourlyData.isEmpty) {
      return _buildEmptyState(theme);
    }

    final hourlySteps = _aggregateByHour();
    final maxSteps = _calculateMaxSteps(hourlySteps);

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight > 0
            ? constraints.maxHeight
            : 200.0;

        return SizedBox(
          height: chartHeight,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 23,
              minY: 0,
              maxY: maxSteps * 1.1,
              lineTouchData: _buildLineTouchData(context, hourlySteps),
              titlesData: _buildTitlesData(theme),
              gridData: _buildGridData(colorScheme, maxSteps),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _buildLineBarData(
                  hourlySteps,
                  effectiveLineColor,
                  effectiveGradientColors,
                  effectiveDotColor,
                ),
              ],
              backgroundColor: backgroundColor,
            ),
            duration: const Duration(milliseconds: 300),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: AppSpacing.iconLg,
            color: theme.colorScheme.outline,
          ),
          AppSpacing.gapVerticalSm,
          Text(
            'No hourly data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Aggregates step records by hour, returning a map of hour -> total steps.
  Map<int, int> _aggregateByHour() {
    final hourlySteps = <int, int>{};

    // Initialize all hours with 0
    for (var i = 0; i < 24; i++) {
      hourlySteps[i] = 0;
    }

    // Sum up steps by hour
    for (final record in hourlyData) {
      final hour = record.recordedAt.hour;
      hourlySteps[hour] = (hourlySteps[hour] ?? 0) + record.stepCount;
    }

    return hourlySteps;
  }

  double _calculateMaxSteps(Map<int, int> hourlySteps) {
    if (hourlySteps.isEmpty) return 1000;
    final max = hourlySteps.values.reduce((a, b) => a > b ? a : b).toDouble();
    return max > 0 ? max : 1000;
  }

  LineTouchData _buildLineTouchData(
    BuildContext context,
    Map<int, int> hourlySteps,
  ) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Theme.of(context).colorScheme.inverseSurface,
        tooltipRoundedRadius: AppSpacing.radiusMd,
        tooltipPadding: AppSpacing.allSm,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final hour = spot.x.toInt();
            final steps = hourlySteps[hour] ?? 0;
            return LineTooltipItem(
              '${_formatHour(hour)}\n',
              TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: '$steps steps',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData(ThemeData theme) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 4,
          getTitlesWidget: (value, meta) {
            final hour = value.toInt();
            if (hour < 0 || hour > 23 || hour % 4 != 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                _formatHour(hour),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  FlGridData _buildGridData(ColorScheme colorScheme, double maxSteps) {
    if (!showGrid) {
      return const FlGridData(show: false);
    }

    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: maxSteps / 4,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  LineChartBarData _buildLineBarData(
    Map<int, int> hourlySteps,
    Color lineColor,
    List<Color> gradientColors,
    Color dotColor,
  ) {
    final spots = hourlySteps.entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.toDouble(),
            ))
        .toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: lineColor,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: showDots,
        getDotPainter: (spot, percent, bar, index) {
          // Only show dots for non-zero values
          if (spot.y == 0) {
            return FlDotCirclePainter(
              radius: 0,
              color: Colors.transparent,
              strokeWidth: 0,
              strokeColor: Colors.transparent,
            );
          }
          return FlDotCirclePainter(
            radius: 4,
            color: dotColor,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  /// Formats an hour (0-23) to a readable string (e.g., "6am", "2pm").
  String _formatHour(int hour) {
    if (hour == 0) return '12am';
    if (hour == 12) return '12pm';
    if (hour < 12) return '${hour}am';
    return '${hour - 12}pm';
  }
}
