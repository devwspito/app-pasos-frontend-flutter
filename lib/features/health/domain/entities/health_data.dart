/// Health data entity for the health domain.
///
/// This is a pure domain entity representing aggregated health data
/// from native health platforms (Apple Health or Google Fit).
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

import 'package:app_pasos_frontend/features/health/domain/entities/step_sample.dart';

/// Represents aggregated health data for a specific date range.
///
/// This entity captures step data from native health platforms
/// including the total steps and individual samples.
///
/// Example usage:
/// ```dart
/// final healthData = HealthData(
///   totalSteps: 8500,
///   startDate: DateTime(2024, 1, 15),
///   endDate: DateTime(2024, 1, 15, 23, 59, 59),
///   samples: [sample1, sample2, sample3],
/// );
/// ```
class HealthData extends Equatable {
  /// Creates a [HealthData] instance.
  ///
  /// [totalSteps] - The total number of steps in this date range.
  /// [startDate] - The start date/time of this data period.
  /// [endDate] - The end date/time of this data period.
  /// [samples] - The list of individual step samples.
  const HealthData({
    required this.totalSteps,
    required this.startDate,
    required this.endDate,
    required this.samples,
  });

  /// The total number of steps in this date range.
  final int totalSteps;

  /// The start date/time of this data period.
  final DateTime startDate;

  /// The end date/time of this data period.
  final DateTime endDate;

  /// The list of individual step samples.
  final List<StepSample> samples;

  /// Creates an empty health data object for use in initial states.
  ///
  /// Useful for initializing state before data is loaded.
  factory HealthData.empty() => HealthData(
        totalSteps: 0,
        startDate: DateTime.fromMillisecondsSinceEpoch(0),
        endDate: DateTime.fromMillisecondsSinceEpoch(0),
        samples: const [],
      );

  /// Whether this is an empty/uninitialized health data.
  bool get isEmpty => totalSteps == 0 && samples.isEmpty;

  /// Whether this is valid health data with information.
  bool get isNotEmpty => !isEmpty;

  /// The duration of this data period.
  Duration get duration => endDate.difference(startDate);

  /// The number of individual samples in this data.
  int get sampleCount => samples.length;

  @override
  List<Object?> get props => [totalSteps, startDate, endDate, samples];

  @override
  String toString() {
    return 'HealthData(totalSteps: $totalSteps, startDate: $startDate, endDate: $endDate, samples: ${samples.length} samples)';
  }
}
