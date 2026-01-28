/// Step sample entity for the health domain.
///
/// This is a pure domain entity representing a single step sample
/// from the native health platform (Apple Health or Google Fit).
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents a single step sample from native health platforms.
///
/// This entity captures granular step data from health platforms
/// including the exact time range and source application.
///
/// Example usage:
/// ```dart
/// final sample = StepSample(
///   steps: 250,
///   startTime: DateTime(2024, 1, 15, 14, 0),
///   endTime: DateTime(2024, 1, 15, 14, 30),
///   source: 'com.apple.health',
/// );
/// ```
class StepSample extends Equatable {
  /// Creates a [StepSample] instance.
  ///
  /// [steps] - The number of steps recorded in this sample.
  /// [startTime] - The start time of this sample period.
  /// [endTime] - The end time of this sample period.
  /// [source] - The source application identifier
  ///            (e.g., 'com.apple.health', 'com.google.android.apps.fitness').
  const StepSample({
    required this.steps,
    required this.startTime,
    required this.endTime,
    required this.source,
  });

  /// The number of steps recorded in this sample.
  final int steps;

  /// The start time of this sample period.
  final DateTime startTime;

  /// The end time of this sample period.
  final DateTime endTime;

  /// The source application identifier.
  ///
  /// Common values:
  /// - 'com.apple.health' - Apple Health
  /// - 'com.google.android.apps.fitness' - Google Fit
  final String source;

  /// Creates an empty step sample for use in initial states.
  ///
  /// Useful for initializing state before data is loaded.
  factory StepSample.empty() => StepSample(
        steps: 0,
        startTime: DateTime.fromMillisecondsSinceEpoch(0),
        endTime: DateTime.fromMillisecondsSinceEpoch(0),
        source: '',
      );

  /// Whether this is an empty/uninitialized sample.
  bool get isEmpty => steps == 0 && source.isEmpty;

  /// Whether this is a valid sample with data.
  bool get isNotEmpty => !isEmpty;

  /// The duration of this sample period.
  Duration get duration => endTime.difference(startTime);

  @override
  List<Object?> get props => [steps, startTime, endTime, source];

  @override
  String toString() {
    return 'StepSample(steps: $steps, startTime: $startTime, endTime: $endTime, source: $source)';
  }
}
