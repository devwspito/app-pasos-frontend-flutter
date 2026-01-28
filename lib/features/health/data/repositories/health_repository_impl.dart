/// Health repository implementation.
///
/// This file implements the [HealthRepository] interface, coordinating
/// data operations through the local datasource for native health platforms.
library;

import 'package:app_pasos_frontend/features/health/data/datasources/health_local_datasource.dart';
import 'package:app_pasos_frontend/features/health/data/models/health_data_model.dart';
import 'package:app_pasos_frontend/features/health/data/models/step_sample_model.dart';
import 'package:app_pasos_frontend/features/health/domain/entities/health_data.dart';
import 'package:app_pasos_frontend/features/health/domain/repositories/health_repository.dart';

/// Implementation of [HealthRepository] using the local datasource.
///
/// This class implements the health business logic, making native
/// health platform calls through the datasource and returning domain entities.
///
/// Example usage:
/// ```dart
/// final repository = HealthRepositoryImpl(
///   datasource: healthDatasource,
/// );
///
/// final hasPermissions = await repository.hasPermissions();
/// if (!hasPermissions) {
///   await repository.requestPermissions();
/// }
///
/// final todaySteps = await repository.getTodayStepsFromHealth();
/// ```
class HealthRepositoryImpl implements HealthRepository {
  /// Creates a [HealthRepositoryImpl] with the required dependencies.
  ///
  /// [datasource] - The local datasource for health platform calls.
  HealthRepositoryImpl({
    required HealthLocalDatasource datasource,
  }) : _datasource = datasource;

  /// The local datasource for health platform operations.
  final HealthLocalDatasource _datasource;

  @override
  Future<bool> requestPermissions() async {
    // Delegate to datasource
    return _datasource.requestPermissions();
  }

  @override
  Future<bool> hasPermissions() async {
    // Delegate to datasource
    return _datasource.hasPermissions();
  }

  @override
  Future<HealthData> getStepsForDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    // Get step samples from datasource
    final samples = await _datasource.getStepSamples(
      start: start,
      end: end,
    );

    // Calculate total steps from samples
    final totalSteps = samples.fold<int>(
      0,
      (sum, sample) => sum + sample.steps,
    );

    // Create and return the health data model
    // The model extends HealthData, so it can be returned as the entity type
    return HealthDataModel(
      totalSteps: totalSteps,
      startDate: start,
      endDate: end,
      samples: samples,
    );
  }

  @override
  Future<int> getTodayStepsFromHealth() async {
    // Delegate to datasource for efficient total calculation
    return _datasource.getTodaySteps();
  }
}
