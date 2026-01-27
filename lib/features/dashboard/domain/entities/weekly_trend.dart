/// Weekly trend entity for the dashboard domain.
///
/// This is a pure domain entity representing daily step totals for trend analysis.
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents a single day's step total in a weekly trend.
///
/// This entity is used to track daily step counts for displaying
/// trends and charts over a week or other time period.
///
/// Example usage:
/// ```dart
/// final trend = WeeklyTrend(
///   date: '2024-01-15',
///   total: 8500,
/// );
/// ```
class WeeklyTrend extends Equatable {
  /// Creates a [WeeklyTrend] instance.
  ///
  /// [date] - The date in YYYY-MM-DD format.
  /// [total] - The total steps for that day.
  const WeeklyTrend({
    required this.date,
    required this.total,
  });

  /// The date in YYYY-MM-DD format.
  final String date;

  /// The total steps recorded for this day.
  final int total;

  /// Creates an empty weekly trend for use in initial states.
  ///
  /// Useful for initializing state before data is loaded.
  factory WeeklyTrend.empty() => const WeeklyTrend(
        date: '',
        total: 0,
      );

  /// Whether this is an empty/uninitialized trend.
  bool get isEmpty => date.isEmpty;

  /// Whether this is a valid trend with data.
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [date, total];

  @override
  String toString() {
    return 'WeeklyTrend(date: $date, total: $total)';
  }
}
