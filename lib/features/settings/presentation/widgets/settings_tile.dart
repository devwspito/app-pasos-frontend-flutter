/// Settings tile widget for individual settings items.
///
/// This widget provides a consistent ListTile-based UI for settings items
/// with support for leading icons, trailing widgets, and tap handlers.
library;

import 'package:flutter/material.dart';

/// A reusable tile widget for settings list items.
///
/// Displays a setting option with optional leading icon, subtitle,
/// trailing widget (like Switch or Icon), and tap handler.
///
/// Example usage:
/// ```dart
/// // Toggle setting
/// SettingsTile(
///   title: 'Enable Notifications',
///   leading: Icon(Icons.notifications_outlined),
///   trailing: Switch(
///     value: settings.notificationsEnabled,
///     onChanged: (value) => updateSetting(value),
///   ),
/// )
///
/// // Navigation setting
/// SettingsTile(
///   title: 'Theme',
///   subtitle: 'Light',
///   leading: Icon(Icons.palette_outlined),
///   onTap: () => showThemeDialog(),
/// )
/// ```
class SettingsTile extends StatelessWidget {
  /// Creates a [SettingsTile] widget.
  ///
  /// [title] is required and displayed as the primary text.
  /// [subtitle] is optional secondary text displayed below the title.
  /// [leading] is typically an icon displayed at the start.
  /// [trailing] is typically a switch or icon at the end.
  /// [onTap] is called when the tile is tapped.
  const SettingsTile({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  /// The primary text displayed on the tile.
  final String title;

  /// Optional secondary text displayed below the title.
  final String? subtitle;

  /// Widget displayed at the start of the tile.
  ///
  /// Typically an [Icon] widget.
  final Widget? leading;

  /// Widget displayed at the end of the tile.
  ///
  /// Typically a [Switch], [Icon], or [Text] widget.
  final Widget? trailing;

  /// Callback invoked when the tile is tapped.
  ///
  /// If null, the tile is not tappable but trailing widgets
  /// may still be interactive.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
