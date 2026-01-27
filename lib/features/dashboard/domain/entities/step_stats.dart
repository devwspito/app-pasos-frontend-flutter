/// Step statistics entity for the dashboard domain.
///
/// This is a pure domain entity representing aggregated step statistics.
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents aggregated step statistics for different time periods.
///
/// This entity provides a summary of steps across various timeframes,
/// useful for displaying dashboard metrics and tracking progress.
///
/// Example usage:
/// ```dart
/// final stats = StepStats(
///   today: 5000,
///   week: 35000,
///   month: 150000,
///   allTime: 1500000,
/// );
/// ```
class StepStats extends Equatable {
  /// Creates a [StepStats] instance.
  ///
  /// [today] - Total steps recorded today.
  /// [week] - Total steps recorded this week.
  /// [month] - Total steps recorded this month.
  /// [allTime] - Total steps recorded all time.
  const StepStats({
    required this.today,
    required this.week,
    required this.month,
    required this.allTime,
  });

  /// Total steps recorded today.
  final int today;

  /// Total steps recorded this week (last 7 days).
  final int week;

  /// Total steps recorded this month.
  final int month;

  /// Total steps recorded all time.
  final int allTime;

  /// Creates empty statistics for use in initial states.
  ///
  /// Useful for initializing state before data is loaded.
  factory StepStats.empty() => const StepStats(
        today: 0,
        week: 0,
        month: 0,
        allTime: 0,
      );

  /// Whether this stats object has any recorded steps.
  bool get isEmpty => today == 0 && week == 0 && month == 0 && allTime == 0;

  /// Whether this stats object has some recorded steps.
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [today, week, month, allTime];

  @override
  String toString() {
    return 'StepStats(today: $today, week: $week, month: $month, allTime: $allTime)';
  }
}
