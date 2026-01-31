/// Settings page for managing user preferences and account.
///
/// This page displays settings sections for notifications, appearance,
/// and account management. Uses SettingsBloc for state management.
library;

import 'package:app_pasos_frontend/core/router/route_names.dart';
import 'package:app_pasos_frontend/features/settings/domain/entities/user_settings.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_event.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_state.dart';
import 'package:app_pasos_frontend/features/settings/presentation/widgets/settings_section.dart';
import 'package:app_pasos_frontend/features/settings/presentation/widgets/settings_tile.dart';
import 'package:app_pasos_frontend/shared/widgets/app_scaffold.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Extension to capitalize strings for display.
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// The main settings page widget.
///
/// Displays user settings with sections for notifications, appearance,
/// and account management. Uses [SettingsBloc] for state management.
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.settings,
///   name: 'settings',
///   builder: (context, state) => BlocProvider(
///     create: (_) => sl<SettingsBloc>()..add(const SettingsLoadRequested()),
///     child: const SettingsPage(),
///   ),
/// )
/// ```
class SettingsPage extends StatelessWidget {
  /// Creates a [SettingsPage] widget.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings updated successfully')),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is SettingsAccountDeleted) {
            context.go(RouteNames.login);
          }
        },
        builder: (context, state) {
          return switch (state) {
            SettingsInitial() || SettingsLoading() => const LoadingIndicator(),
            SettingsLoaded(:final settings) ||
            SettingsUpdating(:final settings) ||
            SettingsUpdateSuccess(:final settings) =>
              _buildContent(context, settings, state is SettingsUpdating),
            SettingsError(:final message, :final settings) =>
              settings != null
                  ? _buildContent(context, settings, false)
                  : _buildErrorContent(context, message),
            SettingsAccountDeleted() => const LoadingIndicator(),
          };
        },
      ),
    );
  }

  /// Builds the main settings content with all sections.
  Widget _buildContent(
    BuildContext context,
    UserSettings settings,
    bool isUpdating,
  ) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationsSection(context, settings),
              const SizedBox(height: 24),
              _buildAppearanceSection(context, settings),
              const SizedBox(height: 24),
              _buildAccountSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
        if (isUpdating)
          const Positioned.fill(
            child: LoadingIndicator(overlay: true, message: 'Updating...'),
          ),
      ],
    );
  }

  /// Builds the notifications settings section.
  Widget _buildNotificationsSection(
    BuildContext context,
    UserSettings settings,
  ) {
    return SettingsSection(
      title: 'Notifications',
      children: [
        SettingsTile(
          title: 'Enable Notifications',
          leading: const Icon(Icons.notifications_outlined),
          trailing: Switch(
            value: settings.notificationsEnabled,
            onChanged: (value) => _updateSettings(
              context,
              settings.copyWith(notificationsEnabled: value),
            ),
          ),
        ),
        SettingsTile(
          title: 'Daily Reminder',
          subtitle: settings.dailyGoalReminder != null
              ? _formatTime(settings.dailyGoalReminder!)
              : 'Not set',
          leading: const Icon(Icons.access_time),
          onTap: () => _showTimePicker(context, settings),
        ),
      ],
    );
  }

  /// Builds the appearance settings section.
  Widget _buildAppearanceSection(BuildContext context, UserSettings settings) {
    return SettingsSection(
      title: 'Appearance',
      children: [
        SettingsTile(
          title: 'Theme',
          subtitle: settings.themePreference.name.capitalize(),
          leading: const Icon(Icons.palette_outlined),
          onTap: () => _showThemeDialog(context, settings),
        ),
      ],
    );
  }

  /// Builds the account settings section.
  Widget _buildAccountSection(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: 'Account',
      children: [
        SettingsTile(
          title: 'Logout',
          leading: const Icon(Icons.logout),
          onTap: () => _showLogoutDialog(context),
        ),
        SettingsTile(
          title: 'Delete Account',
          leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  /// Builds the error content when settings loading fails.
  Widget _buildErrorContent(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<SettingsBloc>().add(const SettingsLoadRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats a TimeOfDay to a human-readable string.
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Updates settings via the bloc.
  void _updateSettings(BuildContext context, UserSettings settings) {
    context.read<SettingsBloc>().add(
          SettingsUpdateRequested(settings: settings),
        );
  }

  /// Shows the time picker dialog for daily reminder.
  Future<void> _showTimePicker(
    BuildContext context,
    UserSettings settings,
  ) async {
    final initialTime =
        settings.dailyGoalReminder ?? const TimeOfDay(hour: 9, minute: 0);

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Select Daily Reminder Time',
    );

    if (selectedTime != null && context.mounted) {
      _updateSettings(
        context,
        settings.copyWith(dailyGoalReminder: selectedTime),
      );
    }
  }

  /// Shows the theme selection dialog.
  Future<void> _showThemeDialog(
    BuildContext context,
    UserSettings settings,
  ) async {
    final selected = await showDialog<ThemePreference>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Select Theme'),
        children: ThemePreference.values.map((theme) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop(theme),
            child: Row(
              children: [
                Radio<ThemePreference>(
                  value: theme,
                  groupValue: settings.themePreference,
                  onChanged: (value) => Navigator.of(dialogContext).pop(value),
                ),
                Text(theme.name.capitalize()),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selected != null && context.mounted) {
      _updateSettings(
        context,
        settings.copyWith(themePreference: selected),
      );
    }
  }

  /// Shows the logout confirmation dialog.
  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context.read<SettingsBloc>().add(const SettingsLogoutRequested());
    }
  }

  /// Shows the delete account confirmation dialog.
  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context.read<SettingsBloc>().add(const SettingsDeleteAccountRequested());
    }
  }
}
