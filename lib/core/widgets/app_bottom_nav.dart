import 'package:flutter/material.dart';

/// Model class representing a single navigation item in [AppBottomNav].
///
/// Each item has an icon, optional selected icon, and a label.
class AppBottomNavItem {
  /// Creates an [AppBottomNavItem].
  ///
  /// The [icon] and [label] parameters are required.
  /// If [selectedIcon] is not provided, [icon] will be used for both states.
  const AppBottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  /// The icon to display when this item is not selected.
  final IconData icon;

  /// The icon to display when this item is selected.
  ///
  /// If null, [icon] is used for both selected and unselected states.
  final IconData? selectedIcon;

  /// The label text displayed below the icon.
  final String label;
}

/// A Material 3 bottom navigation bar widget.
///
/// Uses [NavigationBar] (Material 3) instead of the older [BottomNavigationBar].
/// Supports 3-5 navigation items with customizable icons and labels.
///
/// Example:
/// ```dart
/// AppBottomNav(
///   items: [
///     AppBottomNavItem(
///       icon: Icons.home_outlined,
///       selectedIcon: Icons.home,
///       label: 'Home',
///     ),
///     AppBottomNavItem(
///       icon: Icons.search_outlined,
///       selectedIcon: Icons.search,
///       label: 'Search',
///     ),
///     AppBottomNavItem(
///       icon: Icons.person_outline,
///       selectedIcon: Icons.person,
///       label: 'Profile',
///     ),
///   ],
///   currentIndex: 0,
///   onTap: (index) => print('Tapped item $index'),
/// )
/// ```
class AppBottomNav extends StatelessWidget {
  /// Creates an [AppBottomNav] widget.
  ///
  /// The [items] list must contain between 3 and 5 items.
  /// The [currentIndex] must be a valid index within [items].
  /// The [onTap] callback is invoked when a navigation item is tapped.
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : assert(
          items.length >= 3 && items.length <= 5,
          'AppBottomNav requires 3-5 navigation items',
        );

  /// The list of navigation items to display.
  ///
  /// Must contain between 3 and 5 items.
  final List<AppBottomNavItem> items;

  /// The index of the currently selected item.
  ///
  /// Must be a valid index within [items].
  final int currentIndex;

  /// Callback invoked when a navigation item is tapped.
  ///
  /// Receives the index of the tapped item.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      surfaceTintColor: colorScheme.surfaceTint,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: items.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon ?? item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}
