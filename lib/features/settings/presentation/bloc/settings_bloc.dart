/// Settings BLoC for managing application settings state.
///
/// This BLoC handles all settings-related state management using
/// flutter_bloc. It processes settings events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_event.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing settings state.
///
/// This BLoC processes [SettingsEvent]s and emits [SettingsState]s. It uses
/// the [SettingsRepository] for data persistence, following the Dependency
/// Inversion Principle.
///
/// Example usage:
/// ```dart
/// BlocProvider(
///   create: (context) => SettingsBloc(
///     settingsRepository: context.read<SettingsRepository>(),
///   )..add(const SettingsLoadRequested()),
///   child: const SettingsPage(),
/// )
/// ```
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  /// Creates a [SettingsBloc] instance.
  ///
  /// [settingsRepository] - The repository for settings persistence.
  SettingsBloc({
    required SettingsRepository settingsRepository,
  })  : _settingsRepository = settingsRepository,
        super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsNotificationToggled>(_onNotificationToggled);
    on<SettingsThemeModeChanged>(_onThemeModeChanged);
  }

  /// The repository for settings persistence.
  final SettingsRepository _settingsRepository;

  /// Handles [SettingsLoadRequested] events.
  ///
  /// Loads settings from storage and emits [SettingsLoaded] on success
  /// or [SettingsError] on failure.
  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: 'Failed to load settings: $e'));
    }
  }

  /// Handles [SettingsNotificationToggled] events.
  ///
  /// Updates the notifications enabled setting and emits the new state.
  /// On failure, emits [SettingsError] with the error message.
  Future<void> _onNotificationToggled(
    SettingsNotificationToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      await _settingsRepository.updateNotificationsEnabled(
        enabled: event.enabled,
      );
      final updatedSettings = currentState.settings.copyWith(
        notificationsEnabled: event.enabled,
      );
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      emit(
        SettingsError(message: 'Failed to update notification settings: $e'),
      );
    }
  }

  /// Handles [SettingsThemeModeChanged] events.
  ///
  /// Updates the theme mode setting and emits the new state.
  /// On failure, emits [SettingsError] with the error message.
  Future<void> _onThemeModeChanged(
    SettingsThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      await _settingsRepository.updateThemeMode(event.mode);
      final updatedSettings = currentState.settings.copyWith(
        themeMode: event.mode,
      );
      emit(SettingsLoaded(settings: updatedSettings));
    } catch (e) {
      emit(SettingsError(message: 'Failed to update theme settings: $e'));
    }
  }
}
