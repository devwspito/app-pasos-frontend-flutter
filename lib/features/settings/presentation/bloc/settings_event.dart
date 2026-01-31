/// Settings events for the SettingsBloc.
///
/// This file defines all possible events that can be dispatched to the
/// SettingsBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/settings/domain/entities/user_settings.dart';
import 'package:equatable/equatable.dart';

/// Base class for all settings events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class SettingsEvent extends Equatable {
  /// Creates a [SettingsEvent] instance.
  const SettingsEvent();
}

/// Event dispatched when the user's settings should be loaded.
///
/// This event is typically dispatched when:
/// - The settings screen is first opened
/// - The user wants to refresh their settings data
/// - After a successful settings update to reload the data
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

/// Event dispatched when the user requests to update their settings.
///
/// This event is dispatched from the settings form when the user
/// submits their changes.
///
/// Example:
/// ```dart
/// context.read<SettingsBloc>().add(
///   SettingsUpdateRequested(
///     settings: UserSettings(
///       notificationsEnabled: true,
///       themePreference: ThemePreference.dark,
///     ),
///   ),
/// );
/// ```
final class SettingsUpdateRequested extends SettingsEvent {
  /// Creates a [SettingsUpdateRequested] event.
  ///
  /// [settings] - The updated settings to persist.
  const SettingsUpdateRequested({required this.settings});

  /// The updated settings to persist.
  final UserSettings settings;

  @override
  List<Object?> get props => [settings];
}

/// Event dispatched when the user requests to delete their account.
///
/// This event is dispatched when the user confirms account deletion.
/// This action is irreversible.
///
/// Example:
/// ```dart
/// context.read<SettingsBloc>().add(const SettingsDeleteAccountRequested());
/// ```
final class SettingsDeleteAccountRequested extends SettingsEvent {
  /// Creates a [SettingsDeleteAccountRequested] event.
  const SettingsDeleteAccountRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when the user requests to logout.
///
/// This event is dispatched when the user wants to log out of the app.
/// It will clear the session and redirect to the login screen.
///
/// Example:
/// ```dart
/// context.read<SettingsBloc>().add(const SettingsLogoutRequested());
/// ```
final class SettingsLogoutRequested extends SettingsEvent {
  /// Creates a [SettingsLogoutRequested] event.
  const SettingsLogoutRequested();

  @override
  List<Object?> get props => [];
}
