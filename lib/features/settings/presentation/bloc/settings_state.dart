/// Settings states for the SettingsBloc.
///
/// This file defines all possible states that the SettingsBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/settings/domain/entities/user_settings.dart';
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
///       SettingsLoaded(:final settings) => SettingsView(settings: settings),
///       SettingsUpdating(:final settings) =>
///           SettingsView(settings: settings, isUpdating: true),
///       SettingsUpdateSuccess(:final settings) =>
///           SettingsView(settings: settings),
///       SettingsError(:final message) => ErrorView(message: message),
///       SettingsAccountDeleted() => const AccountDeletedView(),
///     };
///   },
/// )
/// ```
sealed class SettingsState extends Equatable {
  /// Creates a [SettingsState] instance.
  const SettingsState();
}

/// Initial state before any settings operation has been performed.
///
/// This is the default state when the SettingsBloc is first created.
/// The settings should transition from this state after loading begins.
///
/// Example:
/// ```dart
/// if (state is SettingsInitial) {
///   // Trigger settings load
///   context.read<SettingsBloc>().add(const SettingsLoadRequested());
/// }
/// ```
final class SettingsInitial extends SettingsState {
  /// Creates a [SettingsInitial] state.
  const SettingsInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that settings data is being loaded.
///
/// This state is emitted when:
/// - The settings screen first loads the user settings
/// - A settings refresh is requested
///
/// Example:
/// ```dart
/// if (state is SettingsLoading) {
///   return const Center(child: CircularProgressIndicator());
/// }
/// ```
final class SettingsLoading extends SettingsState {
  /// Creates a [SettingsLoading] state.
  const SettingsLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that settings data has been successfully loaded.
///
/// This state is emitted after:
/// - Successfully fetching the user's settings from the server
/// - Successfully refreshing settings data
///
/// Contains the [UserSettings] object with settings information.
///
/// Example:
/// ```dart
/// if (state is SettingsLoaded) {
///   return SettingsView(settings: state.settings);
/// }
/// ```
final class SettingsLoaded extends SettingsState {
  /// Creates a [SettingsLoaded] state.
  ///
  /// [settings] - The user's settings data.
  const SettingsLoaded({required this.settings});

  /// The user's settings data.
  final UserSettings settings;

  @override
  List<Object?> get props => [settings];
}

/// State indicating that a settings update is in progress.
///
/// This state is emitted while the settings update request is being processed.
/// It preserves the current settings data so the UI can still display it.
///
/// Example:
/// ```dart
/// if (state is SettingsUpdating) {
///   return SettingsView(
///     settings: state.settings,
///     isUpdating: true,
///   );
/// }
/// ```
final class SettingsUpdating extends SettingsState {
  /// Creates a [SettingsUpdating] state.
  ///
  /// [settings] - The current settings data while updating.
  const SettingsUpdating({required this.settings});

  /// The current settings data while the update is in progress.
  final UserSettings settings;

  @override
  List<Object?> get props => [settings];
}

/// State indicating that a settings update was successful.
///
/// This state is emitted after successfully updating the user's settings.
/// Contains the updated [UserSettings] object with new settings information.
///
/// Example:
/// ```dart
/// if (state is SettingsUpdateSuccess) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     const SnackBar(content: Text('Settings updated successfully!')),
///   );
///   return SettingsView(settings: state.settings);
/// }
/// ```
final class SettingsUpdateSuccess extends SettingsState {
  /// Creates a [SettingsUpdateSuccess] state.
  ///
  /// [settings] - The updated settings data.
  const SettingsUpdateSuccess({required this.settings});

  /// The updated settings data.
  final UserSettings settings;

  @override
  List<Object?> get props => [settings];
}

/// State indicating that a settings operation has failed.
///
/// This state is emitted when an error occurs during:
/// - Settings loading
/// - Settings updating
/// - Account deletion
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is SettingsError) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class SettingsError extends SettingsState {
  /// Creates a [SettingsError] state.
  ///
  /// [message] - A human-readable error message.
  /// [settings] - Optional previous settings to preserve UI state.
  const SettingsError({
    required this.message,
    this.settings,
  });

  /// The error message describing what went wrong.
  final String message;

  /// Optional previous settings to preserve UI state.
  final UserSettings? settings;

  @override
  List<Object?> get props => [message, settings];
}

/// State indicating that the user's account has been deleted.
///
/// This state is emitted after successfully deleting the user's account.
/// The app should navigate to the login screen and clear all local data.
///
/// Example:
/// ```dart
/// if (state is SettingsAccountDeleted) {
///   context.go('/login');
/// }
/// ```
final class SettingsAccountDeleted extends SettingsState {
  /// Creates a [SettingsAccountDeleted] state.
  const SettingsAccountDeleted();

  @override
  List<Object?> get props => [];
}
