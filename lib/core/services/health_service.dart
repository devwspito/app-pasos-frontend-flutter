/// Health service for native health platform integration in App Pasos.
///
/// This file defines an abstract interface for health data operations.
/// Implementations will provide platform-specific integrations with
/// HealthKit (iOS) and Health Connect (Android).
library;

import 'package:equatable/equatable.dart';

/// Represents a single step count record from the health platform.
///
/// Each record captures step data for a specific time period, including
/// the step count and the time range during which the steps were recorded.
///
/// Example usage:
/// ```dart
/// final record = HealthStepRecord(
///   steps: 1500,
///   startTime: DateTime(2024, 1, 15, 9, 0),
///   endTime: DateTime(2024, 1, 15, 10, 0),
/// );
/// print(record.steps); // 1500
/// ```
class HealthStepRecord extends Equatable {
  /// Creates a [HealthStepRecord] with the given step data.
  ///
  /// All parameters are required:
  /// - [steps] - The number of steps recorded during this period.
  /// - [startTime] - The beginning of the recording period.
  /// - [endTime] - The end of the recording period.
  const HealthStepRecord({
    required this.steps,
    required this.startTime,
    required this.endTime,
  });

  /// The number of steps recorded during this time period.
  final int steps;

  /// The start time of the recording period.
  final DateTime startTime;

  /// The end time of the recording period.
  final DateTime endTime;

  @override
  List<Object?> get props => [steps, startTime, endTime];
}

/// Abstract interface for health platform operations.
///
/// This interface enables dependency injection and testing by allowing
/// mock implementations. All health data access should go through
/// this service.
///
/// Platform implementations:
/// - iOS: HealthKit integration
/// - Android: Health Connect integration
///
/// Example usage:
/// ```dart
/// final healthService = HealthServiceImpl();
/// if (await healthService.isAvailable()) {
///   final hasPermission = await healthService.requestPermission();
///   if (hasPermission) {
///     final steps = await healthService.getTodaySteps();
///     print('Today\'s steps: $steps');
///   }
/// }
/// ```
abstract interface class HealthService {
  /// Checks if the health platform is available on this device.
  ///
  /// Returns `true` if the platform supports health data access:
  /// - iOS: HealthKit is available
  /// - Android: Health Connect is installed and available
  ///
  /// Returns `false` if health features are not supported.
  Future<bool> isAvailable();

  /// Checks if the app has permission to read health data.
  ///
  /// Returns `true` if the user has granted read permissions for step data.
  /// Returns `false` if permissions have not been granted or were denied.
  Future<bool> hasPermission();

  /// Requests permission to access health data from the user.
  ///
  /// Displays the platform-specific permission dialog to the user.
  ///
  /// Returns `true` if the user grants permission.
  /// Returns `false` if the user denies permission or the dialog is dismissed.
  ///
  /// Note: On iOS, permissions are requested through HealthKit.
  /// On Android, permissions are requested through Health Connect.
  Future<bool> requestPermission();

  /// Gets the total step count for today.
  ///
  /// Retrieves step data from midnight of the current day until now.
  ///
  /// Returns the total number of steps recorded today.
  /// Returns `0` if no steps have been recorded or if there's an error.
  ///
  /// Throws an exception if called without proper permissions.
  Future<int> getTodaySteps();

  /// Gets step records for a specific date range.
  ///
  /// [start] - The beginning of the date range (inclusive).
  /// [end] - The end of the date range (inclusive).
  ///
  /// Returns a list of [HealthStepRecord] objects, each representing
  /// a distinct recording period within the specified range.
  ///
  /// The list may be empty if no steps were recorded during the range.
  /// Records are sorted by [HealthStepRecord.startTime] in ascending order.
  ///
  /// Throws an exception if called without proper permissions or if
  /// [start] is after [end].
  ///
  /// Example:
  /// ```dart
  /// final records = await healthService.getStepsForDateRange(
  ///   start: DateTime(2024, 1, 1),
  ///   end: DateTime(2024, 1, 7),
  /// );
  /// for (final record in records) {
  ///   print('${record.startTime}: ${record.steps} steps');
  /// }
  /// ```
  Future<List<HealthStepRecord>> getStepsForDateRange({
    required DateTime start,
    required DateTime end,
  });
}
