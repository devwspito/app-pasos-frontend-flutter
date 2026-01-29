/// Sync native steps use case.
///
/// This use case orchestrates fetching steps from the native health platform
/// (HealthKit on iOS, Health Connect on Android) and recording them to the
/// backend API.
library;

import 'package:app_pasos_frontend/core/services/health_service.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';

/// Use case for syncing steps from the native health platform to the backend.
///
/// This follows Clean Architecture by orchestrating between the health service
/// (for native platform data) and the steps repository (for backend persistence).
///
/// The use case handles:
/// 1. Checking if the health platform is available
/// 2. Checking/requesting permissions from the user
/// 3. Fetching today's step count from the native platform
/// 4. Recording the steps to the backend with [StepSource.native]
///
/// Example usage:
/// ```dart
/// final useCase = SyncNativeStepsUseCase(
///   healthService: healthService,
///   stepsRepository: stepsRepository,
/// );
/// final syncedSteps = await useCase();
/// if (syncedSteps != null) {
///   print('Synced $syncedSteps steps from native health platform');
/// } else {
///   print('Sync failed or unavailable');
/// }
/// ```
class SyncNativeStepsUseCase {
  /// Creates a [SyncNativeStepsUseCase] instance.
  ///
  /// [healthService] - The health service for native platform access.
  /// [stepsRepository] - The steps repository for backend persistence.
  SyncNativeStepsUseCase({
    required HealthService healthService,
    required StepsRepository stepsRepository,
  })  : _healthService = healthService,
        _stepsRepository = stepsRepository;

  final HealthService _healthService;
  final StepsRepository _stepsRepository;

  /// Executes the sync operation.
  ///
  /// Returns the number of steps synced on success.
  /// Returns `null` if:
  /// - The health platform is not available on this device
  /// - The user denied permission to access health data
  /// - The sync operation failed for any other reason
  ///
  /// This method gracefully handles permission denial by returning `null`
  /// instead of throwing an exception, allowing the calling code to handle
  /// the unavailability case appropriately.
  Future<int?> call() async {
    // Step 1: Check if health service is available on this device
    final isAvailable = await _healthService.isAvailable();
    if (!isAvailable) {
      return null;
    }

    // Step 2: Check if we already have permission
    var hasPermission = await _healthService.hasPermission();

    // Step 3: If no permission, request it from the user
    if (!hasPermission) {
      hasPermission = await _healthService.requestPermission();
      if (!hasPermission) {
        // User denied permission - return null gracefully
        return null;
      }
    }

    // Step 4: Get today's steps from native health platform
    final int nativeSteps;
    try {
      nativeSteps = await _healthService.getTodaySteps();
    } catch (_) {
      // Failed to get steps from health platform
      return null;
    }

    // Step 5: Record steps to backend with native source
    // Only sync if there are steps to record
    if (nativeSteps <= 0) {
      return 0;
    }

    try {
      await _stepsRepository.recordSteps(
        count: nativeSteps,
        source: StepSource.native,
      );
      return nativeSteps;
    } catch (_) {
      // Failed to record to backend
      return null;
    }
  }
}
