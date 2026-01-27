/// Hourly peak entity for the dashboard domain.
///
/// This is a pure domain entity representing step totals by hour of day.
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents step totals for a specific hour of the day.
///
/// This entity is used to analyze when users are most active
/// and identify peak activity hours for the dashboard.
///
/// Example usage:
/// ```dart
/// final peak = HourlyPeak(
///   hour: 14,  // 2 PM
///   total: 1200,
/// );
/// ```
class HourlyPeak extends Equatable {
  /// Creates an [HourlyPeak] instance.
  ///
  /// [hour] - The hour of the day (0-23).
  /// [total] - The total steps recorded during this hour.
  const HourlyPeak({
    required this.hour,
    required this.total,
  });

  /// The hour of the day (0-23).
  ///
  /// 0 = midnight, 12 = noon, 23 = 11 PM.
  final int hour;

  /// The total steps recorded during this hour.
  final int total;

  /// Creates an empty hourly peak for use in initial states.
  ///
  /// Useful for initializing state before data is loaded.
  factory HourlyPeak.empty() => const HourlyPeak(
        hour: 0,
        total: 0,
      );

  /// Whether this peak has any recorded steps.
  bool get isEmpty => total == 0;

  /// Whether this peak has some recorded steps.
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [hour, total];

  @override
  String toString() {
    return 'HourlyPeak(hour: $hour, total: $total)';
  }
}
