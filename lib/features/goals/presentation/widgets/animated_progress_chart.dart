/// Animated progress chart widget using fl_chart.
///
/// Displays goal progress over time as a line chart with gradient fill,
/// smooth curves, and touch tooltips showing date and progress percentage.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A data point representing goal progress at a specific date.
///
/// Used to plot progress history on the [AnimatedProgressChart].
///
/// Example usage:
/// ```dart
/// final point = GoalProgressPoint(
///   date: DateTime(2024, 1, 15),
///   currentSteps: 5000,
///   progressPercentage: 50.0,
/// );
/// ```
class GoalProgressPoint {
  /// Creates a [GoalProgressPoint] instance.
  ///
  /// [date] - The date of this progress measurement.
  /// [currentSteps] - The step count at this date.
  /// [progressPercentage] - The progress percentage (0-100) at this date.
  const GoalProgressPoint({
    required this.date,
    required this.currentSteps,
    required this.progressPercentage,
  });

  /// The date of this progress measurement.
  final DateTime date;

  /// The step count at this date.
  final int currentSteps;

  /// The progress percentage (0-100) at this date.
  final double progressPercentage;
}

/// An animated line chart widget that displays goal progress over time.
///
/// Shows progress percentage (0-100%) on the Y-axis and dates on the X-axis.
/// Features smooth curved lines, gradient fill below the line, and
/// touch tooltips showing date and progress percentage.
///
/// The chart height is fixed at 200 pixels and includes animated entry
/// when the widget builds.
///
/// Example usage:
/// ```dart
/// AnimatedProgressChart(
///   progressHistory: [
///     GoalProgressPoint(
///       date: DateTime(2024, 1, 15),
///       currentSteps: 5000,
///       progressPercentage: 25.0,
///     ),
///     GoalProgressPoint(
///       date: DateTime(2024, 1, 16),
///       currentSteps: 10000,
///       progressPercentage: 50.0,
///     ),
///     // ...
///   ],
/// )
/// ```
class AnimatedProgressChart extends StatefulWidget {
  /// Creates an [AnimatedProgressChart].
  ///
  /// [progressHistory] - List of progress data points to display.
  const AnimatedProgressChart({
    required this.progressHistory,
    super.key,
  });

  /// The progress history data to display on the chart.
  final List<GoalProgressPoint> progressHistory;

  @override
  State<AnimatedProgressChart> createState() => _AnimatedProgressChartState();
}

class _AnimatedProgressChartState extends State<AnimatedProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle empty state
    if (widget.progressHistory.isEmpty) {
      return _buildEmptyState(theme);
    }

    return SizedBox(
      height: 200,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
            child: LineChart(
              LineChartData(
                gridData: _buildGridData(colorScheme),
                titlesData: _buildTitlesData(theme, colorScheme),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (widget.progressHistory.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  _buildLineChartBarData(colorScheme),
                ],
                lineTouchData: _buildLineTouchData(theme, colorScheme),
              ),
              duration: const Duration(milliseconds: 300),
            ),
          );
        },
      ),
    );
  }

  /// Builds the empty state widget when no data is available.
  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No progress data yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress history will appear as you make steps',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the grid configuration.
  FlGridData _buildGridData(ColorScheme colorScheme) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 25,
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
          interval: _calculateBottomInterval(),
          getTitlesWidget: (value, meta) =>
              _buildBottomTitle(value, theme, colorScheme),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 25,
          getTitlesWidget: (value, meta) =>
              _buildLeftTitle(value, theme, colorScheme),
        ),
      ),
    );
  }

  /// Calculates the interval for bottom axis labels.
  double _calculateBottomInterval() {
    final count = widget.progressHistory.length;
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 30) return 5;
    return (count / 6).ceilToDouble();
  }

  /// Builds a single bottom axis title (date).
  Widget _buildBottomTitle(
    double value,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final index = value.toInt();
    if (index < 0 || index >= widget.progressHistory.length) {
      return const SizedBox.shrink();
    }

    final point = widget.progressHistory[index];
    final dateLabel = _formatShortDate(point.date);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        dateLabel,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
      ),
    );
  }

  /// Builds a single left axis title (percentage).
  Widget _buildLeftTitle(
    double value,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Text(
      '${value.toInt()}%',
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: 10,
      ),
    );
  }

  /// Builds the main line chart bar data with gradient and animation.
  LineChartBarData _buildLineChartBarData(ColorScheme colorScheme) {
    return LineChartBarData(
      spots: _buildAnimatedSpots(),
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
            colorScheme.primary.withOpacity(0.3 * _animation.value),
            colorScheme.primary.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  /// Builds the animated data points for the chart.
  List<FlSpot> _buildAnimatedSpots() {
    return widget.progressHistory.asMap().entries.map((entry) {
      final animatedY = entry.value.progressPercentage * _animation.value;
      return FlSpot(
        entry.key.toDouble(),
        animatedY.clamp(0, 100),
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
            if (index < 0 || index >= widget.progressHistory.length) {
              return null;
            }
            final point = widget.progressHistory[index];
            return LineTooltipItem(
              '${_formatDate(point.date)}\n',
              theme.textTheme.bodySmall!.copyWith(
                color: colorScheme.onInverseSurface,
                fontSize: 11,
              ),
              children: [
                TextSpan(
                  text: '${point.progressPercentage.toStringAsFixed(1)}%',
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

  /// Formats a date for short display (e.g., "15").
  String _formatShortDate(DateTime date) {
    return date.day.toString();
  }

  /// Formats a date for tooltip display.
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
