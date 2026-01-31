/// Remote data source for settings operations.
///
/// This file defines the interface and implementation for settings
/// API calls using the ApiClient.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/network/api_client.dart';
import 'package:app_pasos_frontend/core/network/api_endpoints.dart';
import 'package:app_pasos_frontend/features/settings/data/models/user_settings_model.dart';

/// Abstract interface for settings remote data operations.
///
/// This interface defines all settings-related API calls.
/// Implementations should use the [ApiClient] for network requests.
abstract interface class SettingsRemoteDatasource {
  /// Gets the current user's settings from the server.
  ///
  /// Returns [UserSettingsModel] with the user's settings data.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<UserSettingsModel> getSettings();

  /// Updates the user's settings on the server.
  ///
  /// [settings] - The updated settings to persist.
  ///
  /// Returns [UserSettingsModel] with the updated settings.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ValidationException] if settings are invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<UserSettingsModel> updateSettings(UserSettingsModel settings);

  /// Deletes the user's account on the server.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> deleteAccount();
}

/// Implementation of [SettingsRemoteDatasource] using [ApiClient].
///
/// This class handles all settings API calls, converting
/// responses to models and handling errors appropriately.
///
/// Example usage:
/// ```dart
/// final datasource = SettingsRemoteDatasourceImpl(client: apiClient);
/// final settings = await datasource.getSettings();
/// ```
class SettingsRemoteDatasourceImpl implements SettingsRemoteDatasource {
  /// Creates a [SettingsRemoteDatasourceImpl] with the given [ApiClient].
  ///
  /// [client] - The API client for making HTTP requests.
  SettingsRemoteDatasourceImpl({required ApiClient client}) : _client = client;

  /// The API client for making HTTP requests.
  final ApiClient _client;

  @override
  Future<UserSettingsModel> getSettings() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.settings,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    // Some APIs return { settings: {...} } and some return settings directly
    final settingsData = data['settings'] as Map<String, dynamic>? ?? data;
    return UserSettingsModel.fromJson(settingsData);
  }

  @override
  Future<UserSettingsModel> updateSettings(UserSettingsModel settings) async {
    final response = await _client.put<Map<String, dynamic>>(
      ApiEndpoints.updateSettings,
      data: settings.toJson(),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final settingsData = data['settings'] as Map<String, dynamic>? ?? data;
    return UserSettingsModel.fromJson(settingsData);
  }

  @override
  Future<void> deleteAccount() async {
    await _client.delete<Map<String, dynamic>>(
      ApiEndpoints.deleteAccount,
    );
  }
}
