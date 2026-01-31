/// Settings BLoC for managing settings state.
///
/// This BLoC handles all settings-related state management using
/// flutter_bloc. It processes settings events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_pasos_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_event.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing settings state.
///
/// This BLoC processes [SettingsEvent]s and emits [SettingsState]s. It uses
/// repositories for business logic, following the Dependency Inversion Principle.
///
/// Example usage:
/// ```dart
/// // Create SettingsBloc with dependencies
/// final settingsBloc = SettingsBloc(
///   repository: getIt<SettingsRepository>(),
///   authRepository: getIt<AuthRepository>(),
/// );
///
/// // Use in a BlocProvider
/// BlocProvider(
///   create: (context) => settingsBloc..add(const SettingsLoadRequested()),
///   child: const SettingsScreen(),
/// )
/// ```
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  /// Creates a [SettingsBloc] instance.
  ///
  /// [repository] - Repository for settings operations.
  /// [authRepository] - Repository for authentication operations (logout).
  SettingsBloc({
    required SettingsRepository repository,
    required AuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository,
        super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsUpdateRequested>(_onUpdateRequested);
    on<SettingsDeleteAccountRequested>(_onDeleteAccountRequested);
    on<SettingsLogoutRequested>(_onLogoutRequested);
  }

  final SettingsRepository _repository;
  final AuthRepository _authRepository;

  /// Handles [SettingsLoadRequested] events.
  ///
  /// Fetches the current user's settings from the server and emits
  /// the appropriate state based on the result.
  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(settings: settings));
    } on AppException catch (e) {
      emit(SettingsError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(SettingsError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [SettingsUpdateRequested] events.
  ///
  /// Updates the user's settings with the provided data,
  /// preserving the current settings data during the update process.
  Future<void> _onUpdateRequested(
    SettingsUpdateRequested event,
    Emitter<SettingsState> emit,
  ) async {
    // Preserve current settings data for updating state
    final currentSettings = switch (state) {
      SettingsLoaded(:final settings) => settings,
      SettingsUpdating(:final settings) => settings,
      SettingsUpdateSuccess(:final settings) => settings,
      SettingsError(:final settings) => settings,
      _ => null,
    };

    if (currentSettings != null) {
      emit(SettingsUpdating(settings: currentSettings));
    } else {
      emit(const SettingsLoading());
    }

    try {
      final updatedSettings = await _repository.updateSettings(event.settings);
      emit(SettingsUpdateSuccess(settings: updatedSettings));
    } on AppException catch (e) {
      emit(SettingsError(
        message: _getErrorMessage(e),
        settings: currentSettings,
      ));
    } catch (e) {
      emit(SettingsError(
        message: 'An unexpected error occurred: $e',
        settings: currentSettings,
      ));
    }
  }

  /// Handles [SettingsDeleteAccountRequested] events.
  ///
  /// Deletes the user's account permanently and emits
  /// [SettingsAccountDeleted] on success.
  Future<void> _onDeleteAccountRequested(
    SettingsDeleteAccountRequested event,
    Emitter<SettingsState> emit,
  ) async {
    // Preserve current settings for error state
    final currentSettings = switch (state) {
      SettingsLoaded(:final settings) => settings,
      SettingsUpdating(:final settings) => settings,
      SettingsUpdateSuccess(:final settings) => settings,
      SettingsError(:final settings) => settings,
      _ => null,
    };

    emit(const SettingsLoading());

    try {
      await _repository.deleteAccount();
      emit(const SettingsAccountDeleted());
    } on AppException catch (e) {
      emit(SettingsError(
        message: _getErrorMessage(e),
        settings: currentSettings,
      ));
    } catch (e) {
      emit(SettingsError(
        message: 'An unexpected error occurred: $e',
        settings: currentSettings,
      ));
    }
  }

  /// Handles [SettingsLogoutRequested] events.
  ///
  /// Logs out the user by calling the auth repository.
  Future<void> _onLogoutRequested(
    SettingsLogoutRequested event,
    Emitter<SettingsState> emit,
  ) async {
    // Preserve current settings for error state
    final currentSettings = switch (state) {
      SettingsLoaded(:final settings) => settings,
      SettingsUpdating(:final settings) => settings,
      SettingsUpdateSuccess(:final settings) => settings,
      SettingsError(:final settings) => settings,
      _ => null,
    };

    emit(const SettingsLoading());

    try {
      await _authRepository.logout();
      // After logout, the auth state listener will handle navigation
      // We emit SettingsInitial to reset the bloc state
      emit(const SettingsInitial());
    } on AppException catch (e) {
      emit(SettingsError(
        message: _getErrorMessage(e),
        settings: currentSettings,
      ));
    } catch (e) {
      emit(SettingsError(
        message: 'An unexpected error occurred: $e',
        settings: currentSettings,
      ));
    }
  }

  /// Converts an [AppException] to a user-friendly error message.
  String _getErrorMessage(AppException exception) {
    return switch (exception) {
      NetworkException(:final isNoConnection, :final isTimeout) =>
        isNoConnection
            ? 'No internet connection. Please check your network.'
            : isTimeout
                ? 'Connection timed out. Please try again.'
                : exception.message,
      ServerException(:final statusCode) => statusCode == 500
          ? 'Server error. Please try again later.'
          : exception.message,
      ValidationException(:final fieldErrors) => fieldErrors.isNotEmpty
          ? fieldErrors.values.expand((e) => e).join('. ')
          : exception.message,
      UnauthorizedException(:final isTokenExpired) => isTokenExpired
          ? 'Your session has expired. Please log in again.'
          : exception.message,
      CacheException() => exception.message,
    };
  }
}
