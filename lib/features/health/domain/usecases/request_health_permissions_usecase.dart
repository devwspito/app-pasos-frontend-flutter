/// Request health permissions use case.
///
/// This use case handles requesting health data permissions from the user.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/health/domain/repositories/health_repository.dart';

/// Use case for requesting health data permissions.
///
/// This follows the Single Responsibility Principle - it only handles
/// requesting permissions from the native health platform. It also follows
/// Dependency Inversion Principle by depending on the HealthRepository
/// interface rather than a concrete implementation.
///
/// On iOS, this will trigger the Apple Health permissions dialog.
/// On Android, this will trigger the Google Fit permissions dialog.
///
/// Example usage:
/// ```dart
/// final useCase = RequestHealthPermissionsUseCase(repository: healthRepository);
/// final granted = await useCase();
/// if (granted) {
///   print('Health permissions granted!');
/// } else {
///   print('Health permissions denied.');
/// }
/// ```
class RequestHealthPermissionsUseCase {
  /// Creates a [RequestHealthPermissionsUseCase] instance.
  ///
  /// [repository] - The health repository interface.
  RequestHealthPermissionsUseCase({required HealthRepository repository})
      : _repository = repository;

  final HealthRepository _repository;

  /// Executes the use case to request health permissions.
  ///
  /// Returns `true` if permissions were granted, `false` otherwise.
  /// Throws [PlatformException] if the health platform is unavailable.
  Future<bool> call() async {
    return _repository.requestPermissions();
  }
}
