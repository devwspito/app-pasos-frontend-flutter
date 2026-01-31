/// Settings repository implementation.
///
/// This file implements the [SettingsRepository] interface, coordinating
/// the remote datasource for settings operations.
library;

import 'package:app_pasos_frontend/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:app_pasos_frontend/features/settings/data/models/user_settings_model.dart';
import 'package:app_pasos_frontend/features/settings/domain/entities/user_settings.dart';
import 'package:app_pasos_frontend/features/settings/domain/repositories/settings_repository.dart';

/// Implementation of [SettingsRepository] using remote datasource.
///
/// This class implements the settings business logic, including:
/// - Making API calls through the datasource
/// - Converting between models and entities
///
/// Example usage:
/// ```dart
/// final repository = SettingsRepositoryImpl(
///   datasource: settingsDatasource,
/// );
///
/// final settings = await repository.getSettings();
/// ```
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates a [SettingsRepositoryImpl] with the required dependencies.
  ///
  /// [datasource] - The remote datasource for API calls.
  SettingsRepositoryImpl({
    required SettingsRemoteDatasource datasource,
  }) : _datasource = datasource;

  /// The remote datasource for API operations.
  final SettingsRemoteDatasource _datasource;

  @override
  Future<UserSettings> getSettings() async {
    return _datasource.getSettings();
  }

  @override
  Future<UserSettings> updateSettings(UserSettings settings) async {
    final model = UserSettingsModel.fromEntity(settings);
    return _datasource.updateSettings(model);
  }

  @override
  Future<void> deleteAccount() async {
    await _datasource.deleteAccount();
  }
}
