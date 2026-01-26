import 'package:equatable/equatable.dart';

/// Domain entity representing health step data retrieved from native health APIs.
///
/// This is an immutable entity that contains business logic methods
/// for health data processing. Unlike data models, entities do NOT
/// contain JSON serialization logic.
///
/// Example usage:
/// ```dart
/// final healthData = HealthData(
///   stepCount: 8500,
///   dateFrom: DateTime(2024, 1, 15, 8, 0),
///   dateTo: DateTime(2024, 1, 15, 9, 0),
///   source: 'healthkit',
///   syncedAt: DateTime.now(),
/// );
///
/// print(healthData.isFromHealthKit); // true
/// print(healthData.isFromHealthConnect); // false
/// ```
class HealthData extends Equatable {
  /// Number of steps recorded in this health data entry.
  final int stepCount;

  /// Start timestamp of the health data measurement period.
  final DateTime dateFrom;

  /// End timestamp of the health data measurement period.
  final DateTime dateTo;

  /// Source of the health data (e.g., 'healthkit', 'health_connect').
  final String source;

  /// Timestamp when this health data was synced from the native health API.
  /// Can be null if the data has not been synced yet.
  final DateTime? syncedAt;

  /// Creates a [HealthData] instance.
  ///
  /// All fields are required except [syncedAt] which can be null.
  const HealthData({
    required this.stepCount,
    required this.dateFrom,
    required this.dateTo,
    required this.source,
    this.syncedAt,
  });

  /// Returns true if this health data came from Apple HealthKit.
  ///
  /// Checks if the source string contains 'healthkit' (case-insensitive).
  bool get isFromHealthKit => source.toLowerCase().contains('healthkit');

  /// Returns true if this health data came from Android Health Connect.
  ///
  /// Checks if the source string contains 'health_connect' (case-insensitive).
  bool get isFromHealthConnect =>
      source.toLowerCase().contains('health_connect');

  /// Creates a copy of this health data with optional field overrides.
  HealthData copyWith({
    int? stepCount,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? source,
    DateTime? syncedAt,
  }) {
    return HealthData(
      stepCount: stepCount ?? this.stepCount,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      source: source ?? this.source,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  List<Object?> get props => [stepCount, dateFrom, dateTo, source, syncedAt];

  @override
  String toString() {
    return 'HealthData(stepCount: $stepCount, dateFrom: $dateFrom, '
        'dateTo: $dateTo, source: $source, syncedAt: $syncedAt)';
  }
}
