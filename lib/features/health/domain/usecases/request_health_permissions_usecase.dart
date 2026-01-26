/// Use case for requesting health data permissions from the user.
///
/// This use case follows the single responsibility principle - it has only
/// one method [call] that requests permissions to access health data
/// through the repository.
///
/// Example usage:
/// ```dart
/// final useCase = RequestHealthPermissionsUseCase(healthRepository);
/// final granted = await useCase();
/// if (granted) {
///   print('Permissions granted! Can now read health data.');
/// } else {
///   print('Permissions denied. Cannot access health data.');
/// }
/// ```
library;

import '../repositories/health_repository.dart';

/// Use case for requesting health data permissions.
///
/// Follows the single responsibility principle with a single [call] method.
/// Inject [HealthRepository] via constructor for dependency injection.
///
/// This use case handles the permission request flow, which will trigger
/// the platform's native health permission dialog (HealthKit on iOS,
/// Health Connect on Android).
///
/// Important considerations:
/// - On iOS, the permission dialog may only be shown once per data type.
///   If the user denies permission, they must enable it in Settings.
/// - On Android, Health Connect must be installed for permissions to work.
/// - The user's choice is persisted by the platform, not the app.
///
/// Example:
/// ```dart
/// final useCase = RequestHealthPermissionsUseCase(repository);
///
/// // Request permissions before reading health data
/// final granted = await useCase();
///
/// if (granted) {
///   // Safe to read health data
///   final steps = await getStepsUseCase(startDate, endDate);
/// } else {
///   // Show UI explaining why permissions are needed
///   showPermissionExplanationDialog();
/// }
/// ```
class RequestHealthPermissionsUseCase {
  /// The repository used to request health permissions.
  final HealthRepository _repository;

  /// Creates a new [RequestHealthPermissionsUseCase] with the given repository.
  ///
  /// [repository] - The health repository implementation to use.
  RequestHealthPermissionsUseCase(this._repository);

  /// Requests permissions to access health data.
  ///
  /// This method will trigger the platform's health data permission dialog,
  /// asking the user to grant read access to step count and related health data.
  ///
  /// Returns a [Future] that completes with:
  /// - `true` if all required permissions were granted
  /// - `false` if any permission was denied or the request failed
  ///
  /// Note: On iOS, even if the user denies permission, this may still return
  /// `true` due to platform limitations in detecting denial. Always verify
  /// actual data access with a test read before assuming permissions are granted.
  ///
  /// Throws an [Exception] if the platform health service is unavailable.
  Future<bool> call() => _repository.requestPermissions();
}
