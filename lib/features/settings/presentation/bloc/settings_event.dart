/// Settings events for the SettingsBloc.
///
/// This file defines all possible events that can be dispatched to the
/// SettingsBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/settings/domain/entities/app_settings.dart';
import 'package:equatable/equatable.dart';

/// Base class for all settings events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class SettingsEvent extends Equatable {
  /// Creates a [SettingsEvent] instance.
  const SettingsEvent();
}

/// Event dispatched to load the current settings.
///
/// This event triggers the loading of settings from storage and
/// should be dispatched when the settings page is initialized.
///
/// Example:
/// ```dart
/// context.read<SettingsBloc>().add(const SettingsLoadRequested());
/// ```
final class SettingsLoadRequested extends SettingsEvent {
  /// Creates a [SettingsLoadRequested] event.
  const SettingsLoadRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when the notifications toggle is changed.
///
/// This event updates the notifications enabled setting in storage.
///
/// Example:
/// ```dart
/// context.read<SettingsBloc>().add(
///   const SettingsNotificationToggled(enabled: false),
/// );
/// ```
final class SettingsNotificationToggled extends SettingsEvent {
  /// Creates a [SettingsNotificationToggled] event.
  ///
  /// [enabled] - The new value for notifications enabled.
  const SettingsNotificationToggled({required this.enabled});

  /// Whether notifications should be enabled.
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Event dispatched when the theme mode is changed.
///
/// This event updates the theme mode setting in storage.
///
/// Example:
/// ```dart
/// context.read<SettingsBloc>().add(
///   const SettingsThemeModeChanged(mode: AppThemeMode.dark),
/// );
/// ```
final class SettingsThemeModeChanged extends SettingsEvent {
  /// Creates a [SettingsThemeModeChanged] event.
  ///
  /// [mode] - The new [AppThemeMode] to set.
  const SettingsThemeModeChanged({required this.mode});

  /// The new theme mode to apply.
  final AppThemeMode mode;

  @override
  List<Object?> get props => [mode];
}
