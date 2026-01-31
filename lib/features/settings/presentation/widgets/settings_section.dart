/// Settings section widget for grouping related settings.
///
/// This widget provides a consistent container for grouping related
/// settings items with a section header.
library;

import 'package:flutter/material.dart';

/// A section container for grouping related settings items.
///
/// Displays a titled section with a Card containing the children widgets.
/// Used to organize settings into logical groups (Notifications, Appearance,
/// Account, etc.).
///
/// Example usage:
/// ```dart
/// SettingsSection(
///   title: 'Notifications',
///   children: [
///     SettingsTile(
///       title: 'Enable Notifications',
///       trailing: Switch(value: true, onChanged: (_) {}),
///     ),
///     SettingsTile(
///       title: 'Daily Reminder',
///       subtitle: '9:00 AM',
///     ),
///   ],
/// )
/// ```
class SettingsSection extends StatelessWidget {
  /// Creates a [SettingsSection] widget.
  ///
  /// [title] is displayed as the section header.
  /// [children] are the settings items within this section.
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  /// The title displayed above the section.
  final String title;

  /// The list of widgets (typically [SettingsTile]) within this section.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }
}
