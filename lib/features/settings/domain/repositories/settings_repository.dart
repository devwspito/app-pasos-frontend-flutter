/// Settings repository interface for the domain layer.
///
/// This file defines the contract for settings operations.
/// Implementations should handle all settings-related data operations.
library;

import 'package:app_pasos_frontend/features/settings/domain/entities/user_settings.dart';

/// Abstract interface defining settings operations.
///
/// This interface follows the Clean Architecture pattern, allowing the domain
/// layer to define what operations are needed without knowing implementation
/// details. The data layer provides the concrete implementation.
///
/// Example usage:
/// ```dart
/// class GetSettingsUseCase {
///   final SettingsRepository repository;
///
///   GetSettingsUseCase(this.repository);
///
///   Future<UserSettings> execute() {
///     return repository.getSettings();
///   }
/// }
/// ```
abstract interface class SettingsRepository {
  /// Gets the current user's settings.
  ///
  /// Returns the [UserSettings] for the authenticated user.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<UserSettings> getSettings();

  /// Updates the user's settings.
  ///
  /// [settings] - The updated settings to persist.
  ///
  /// Returns the updated [UserSettings] from the server.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ValidationException] if settings are invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<UserSettings> updateSettings(UserSettings settings);

  /// Deletes the user's account permanently.
  ///
  /// This operation is irreversible and will:
  /// - Delete all user data from the server
  /// - Invalidate all sessions
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> deleteAccount();
}
