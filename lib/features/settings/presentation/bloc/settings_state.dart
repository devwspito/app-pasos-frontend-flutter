/// Settings states for the SettingsBloc.
///
/// This file defines all possible states that the SettingsBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/settings/domain/entities/app_settings.dart';
import 'package:equatable/equatable.dart';

/// Base class for all settings states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<SettingsBloc, SettingsState>(
///   builder: (context, state) {
///     return switch (state) {
///       SettingsInitial() => const SizedBox.shrink(),
///       SettingsLoading() => const LoadingIndicator(),
///       SettingsLoaded(:final settings) =>
///           SettingsContent(settings: settings),
///       SettingsError(:final message) => AppErrorWidget(message: message),
///     };
///   },
/// )
/// ```
sealed class SettingsState extends Equatable {
  /// Creates a [SettingsState] instance.
  const SettingsState();
}

/// Initial state before settings have been loaded.
///
/// This is the default state when the SettingsBloc is first created.
/// The UI should transition from this state after dispatching
/// `SettingsLoadRequested`.
final class SettingsInitial extends SettingsState {
  /// Creates a [SettingsInitial] state.
  const SettingsInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that settings are being loaded.
///
/// This state is emitted when:
/// - Initial settings load is in progress
/// - Settings are being saved
///
/// The UI should display a loading indicator when in this state.
final class SettingsLoading extends SettingsState {
  /// Creates a [SettingsLoading] state.
  const SettingsLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that settings have been successfully loaded.
///
/// This state is emitted after:
/// - Successful initial load
/// - Successful settings update
///
/// Contains the current [AppSettings] to display in the UI.
final class SettingsLoaded extends SettingsState {
  /// Creates a [SettingsLoaded] state.
  ///
  /// [settings] - The current application settings.
  const SettingsLoaded({required this.settings});

  /// The current application settings.
  final AppSettings settings;

  @override
  List<Object?> get props => [settings];
}

/// State indicating that a settings error has occurred.
///
/// This state is emitted when an operation fails, such as:
/// - Failed to load settings from storage
/// - Failed to save settings to storage
///
/// Contains an error [message] describing what went wrong.
final class SettingsError extends SettingsState {
  /// Creates a [SettingsError] state.
  ///
  /// [message] - A human-readable error message.
  const SettingsError({required this.message});

  /// The error message describing what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];
}
