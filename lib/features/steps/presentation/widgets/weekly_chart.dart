import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/models/weekly_trend_model.dart';

/// A bar chart widget displaying weekly step trends.
///
/// Shows 7 days of step data with today highlighted.
/// Uses [LayoutBuilder] for responsive sizing.
///
/// Example:
/// ```dart
/// WeeklyChart(
///   weeklyTrend: stepsState.weeklyTrend,
///   onBarTap: (index) => selectDay(index),
/// )
/// ```
class WeeklyChart extends StatelessWidget {
  /// Creates a [WeeklyChart].
  ///
  /// [weeklyTrend] is the list of weekly trend data to display.
  /// [onBarTap] is an optional callback when a bar is tapped.
  const WeeklyChart({
    required this.weeklyTrend,
    this.onBarTap,
    this.barColor,
    this.todayBarColor,
    this.backgroundColor,
    super.key,
  });

  /// The weekly trend data to display.
  final List<WeeklyTrendModel> weeklyTrend;

  /// Callback when a bar is tapped. Returns the index of the tapped bar.
  final ValueChanged<int>? onBarTap;

  /// The color for regular bars.
  final Color? barColor;

  /// The color for today's bar (highlighted).
  final Color? todayBarColor;

  /// The background color of the chart.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBarColor = barColor ?? colorScheme.primary.withOpacity(0.6);
    final effectiveTodayColor = todayBarColor ?? colorScheme.primary;

    if (weeklyTrend.isEmpty) {
      return _buildEmptyState(theme);
    }

    final maxSteps = _calculateMaxSteps();

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight > 0
            ? constraints.maxHeight
            : 200.0;

        return SizedBox(
          height: chartHeight,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxSteps * 1.1,
              minY: 0,
              barTouchData: _buildBarTouchData(context, effectiveTodayColor),
              titlesData: _buildTitlesData(theme),
              gridData: _buildGridData(colorScheme),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(
                effectiveBarColor,
                effectiveTodayColor,
              ),
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
            Icons.bar_chart_rounded,
            size: AppSpacing.iconLg,
            color: theme.colorScheme.outline,
          ),
          AppSpacing.gapVerticalSm,
          Text(
            'No weekly data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMaxSteps() {
    if (weeklyTrend.isEmpty) return 10000;
    final max = weeklyTrend
        .map((e) => e.steps)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    return max > 0 ? max : 10000;
  }

  BarTouchData _buildBarTouchData(BuildContext context, Color highlightColor) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Theme.of(context).colorScheme.inverseSurface,
        tooltipRoundedRadius: AppSpacing.radiusMd,
        tooltipPadding: AppSpacing.allSm,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final trend = weeklyTrend[groupIndex];
          return BarTooltipItem(
            '${trend.dayOfWeek}\n',
            TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            children: [
              TextSpan(
                text: '${trend.steps} steps',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          );
        },
      ),
      touchCallback: (event, response) {
        if (event.isInterestedForInteractions &&
            response?.spot != null &&
            onBarTap != null) {
          onBarTap!(response!.spot!.touchedBarGroupIndex);
        }
      },
    );
  }

  FlTitlesData _buildTitlesData(ThemeData theme) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= weeklyTrend.length) {
              return const SizedBox.shrink();
            }
            final trend = weeklyTrend[index];
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                _abbreviateDay(trend.dayOfWeek),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: trend.isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: trend.isToday ? FontWeight.bold : FontWeight.normal,
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

  FlGridData _buildGridData(ColorScheme colorScheme) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _calculateMaxSteps() / 4,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  List<BarChartGroupData> _buildBarGroups(Color barColor, Color todayColor) {
    return weeklyTrend.asMap().entries.map((entry) {
      final index = entry.key;
      final trend = entry.value;
      final color = trend.isToday ? todayColor : barColor;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: trend.steps.toDouble(),
            color: color,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusSm),
              topRight: Radius.circular(AppSpacing.radiusSm),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxSteps() * 1.1,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      );
    }).toList();
  }

  /// Abbreviates day names to 2-3 characters.
  String _abbreviateDay(String dayOfWeek) {
    final lower = dayOfWeek.toLowerCase();
    switch (lower) {
      case 'monday':
        return 'Mon';
      case 'tuesday':
        return 'Tue';
      case 'wednesday':
        return 'Wed';
      case 'thursday':
        return 'Thu';
      case 'friday':
        return 'Fri';
      case 'saturday':
        return 'Sat';
      case 'sunday':
        return 'Sun';
      default:
        // Return first 3 chars if already abbreviated or unknown
        return dayOfWeek.length > 3 ? dayOfWeek.substring(0, 3) : dayOfWeek;
    }
  }
}
