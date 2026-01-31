/// Settings page for managing application preferences.
///
/// This page provides the user interface for adjusting application settings
/// including notification preferences and theme mode selection.
library;

import 'package:app_pasos_frontend/features/settings/domain/entities/app_settings.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_event.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_state.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Settings page widget for displaying and managing app settings.
///
/// This page displays settings options organized in card sections
/// with immediate persistence on change.
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
class SettingsPage extends StatefulWidget {
  /// Creates a [SettingsPage] instance.
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return switch (state) {
            SettingsInitial() => const LoadingIndicator(
                message: 'Initializing settings...',
              ),
            SettingsLoading() => const LoadingIndicator(
                message: 'Loading settings...',
              ),
            SettingsLoaded(:final settings) => _SettingsContent(
                settings: settings,
              ),
            SettingsError(:final message) => AppErrorWidget(
                message: message,
                onRetry: () => context.read<SettingsBloc>().add(
                      const SettingsLoadRequested(),
                    ),
              ),
          };
        },
      ),
    );
  }
}

/// Content widget displaying the settings options.
class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Notifications Section
        const _SectionHeader(
          title: 'Notifications',
          icon: Icons.notifications_outlined,
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text(
                  'Receive notifications about your activities',
                ),
                value: settings.notificationsEnabled,
                onChanged: (enabled) {
                  context.read<SettingsBloc>().add(
                        SettingsNotificationToggled(enabled: enabled),
                      );
                },
                secondary: Icon(
                  settings.notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off_outlined,
                  color: settings.notificationsEnabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Appearance Section
        const _SectionHeader(
          title: 'Appearance',
          icon: Icons.palette_outlined,
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.brightness_6_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Mode',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose your preferred theme',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppThemeMode>(
                    segments: const [
                      ButtonSegment<AppThemeMode>(
                        value: AppThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<AppThemeMode>(
                        value: AppThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                      ButtonSegment<AppThemeMode>(
                        value: AppThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.phone_android_outlined),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        context.read<SettingsBloc>().add(
                              SettingsThemeModeChanged(mode: selection.first),
                            );
                      }
                    },
                    showSelectedIcon: false,
                  ),
                ),
              ],
            ),
          ),
        ),

        // About Section
        const _SectionHeader(
          title: 'About',
          icon: Icons.info_outline,
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Version'),
                trailing: Text(
                  '1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showInfoSnackBar(context, 'Terms of Service');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showInfoSnackBar(context, 'Privacy Policy');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInfoSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title - Feature available in future update'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Section header widget for grouping settings.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
