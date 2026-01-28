/// Sync steps background use case.
///
/// This use case handles syncing steps from the native health platform
/// to the backend in the background. It coordinates between the health
/// repository (to get steps) and the steps repository (to record them).
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';
import 'package:app_pasos_frontend/features/health/domain/repositories/health_repository.dart';

/// Use case for syncing steps from health platform to backend.
///
/// This follows the Single Responsibility Principle - it only handles
/// the synchronization of step data between health platforms and the backend.
/// It coordinates between two repositories following Clean Architecture:
/// - HealthRepository: Gets steps from native health platform
/// - StepsRepository: Records steps to the backend
///
/// This use case is designed to run in background sync scenarios,
/// such as periodic background fetch or when the app resumes.
///
/// Example usage:
/// ```dart
/// final useCase = SyncStepsBackgroundUseCase(
///   healthRepository: healthRepository,
///   stepsRepository: stepsRepository,
/// );
/// final record = await useCase();
/// print('Synced ${record.count} steps from health platform');
/// ```
class SyncStepsBackgroundUseCase {
  /// Creates a [SyncStepsBackgroundUseCase] instance.
  ///
  /// [healthRepository] - The health repository for getting native steps.
  /// [stepsRepository] - The steps repository for recording to backend.
  SyncStepsBackgroundUseCase({
    required HealthRepository healthRepository,
    required StepsRepository stepsRepository,
  })  : _healthRepository = healthRepository,
        _stepsRepository = stepsRepository;

  final HealthRepository _healthRepository;
  final StepsRepository _stepsRepository;

  /// Executes the use case to sync steps from health platform.
  ///
  /// This method:
  /// 1. Gets today's steps from the native health platform
  /// 2. Records them to the backend with source [StepSource.native]
  ///
  /// Returns the created [StepRecord] on success.
  /// Throws [PermissionDeniedException] if health permissions not granted.
  /// Throws [PlatformException] if the health platform is unavailable.
  /// Throws [HealthDataException] on health data retrieval errors.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<StepRecord> call() async {
    final todaySteps = await _healthRepository.getTodayStepsFromHealth();
    return _stepsRepository.recordSteps(
      count: todaySteps,
      source: StepSource.native,
    );
  }
}
