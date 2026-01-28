/// Health repository interface for the domain layer.
///
/// This file defines the contract for health-related operations
/// interacting with native health platforms (Apple Health, Google Fit).
/// Implementations should handle all health data operations.
library;

import 'package:app_pasos_frontend/features/health/domain/entities/health_data.dart';

/// Abstract interface defining health-related operations.
///
/// This interface follows the Clean Architecture pattern, allowing the domain
/// layer to define what operations are needed without knowing implementation
/// details. The data layer provides the concrete implementation that
/// communicates with native health platforms.
///
/// Example usage:
/// ```dart
/// class GetTodayStepsFromHealthUseCase {
///   final HealthRepository repository;
///
///   GetTodayStepsFromHealthUseCase(this.repository);
///
///   Future<int> execute() async {
///     final hasPerms = await repository.hasPermissions();
///     if (!hasPerms) {
///       await repository.requestPermissions();
///     }
///     return repository.getTodayStepsFromHealth();
///   }
/// }
/// ```
abstract interface class HealthRepository {
  /// Requests health data permissions from the user.
  ///
  /// On iOS, this will show the Apple Health permissions dialog.
  /// On Android, this will show the Google Fit permissions dialog.
  ///
  /// Returns `true` if permissions were granted, `false` otherwise.
  /// Throws [PlatformException] if the health platform is unavailable.
  Future<bool> requestPermissions();

  /// Checks if the app has health data permissions.
  ///
  /// Returns `true` if permissions are granted, `false` otherwise.
  /// Throws [PlatformException] if the health platform is unavailable.
  Future<bool> hasPermissions();

  /// Gets step data for a specific date range from the health platform.
  ///
  /// [start] - The start date/time for the query.
  /// [end] - The end date/time for the query.
  ///
  /// Returns [HealthData] containing total steps and individual samples.
  /// Throws [PermissionDeniedException] if health permissions not granted.
  /// Throws [PlatformException] if the health platform is unavailable.
  /// Throws [HealthDataException] on data retrieval errors.
  Future<HealthData> getStepsForDateRange({
    required DateTime start,
    required DateTime end,
  });

  /// Gets today's total steps from the health platform.
  ///
  /// This is a convenience method that queries from midnight today
  /// until the current time.
  ///
  /// Returns the total step count for today.
  /// Throws [PermissionDeniedException] if health permissions not granted.
  /// Throws [PlatformException] if the health platform is unavailable.
  /// Throws [HealthDataException] on data retrieval errors.
  Future<int> getTodayStepsFromHealth();
}
