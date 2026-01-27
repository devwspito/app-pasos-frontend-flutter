/// Application scaffold widget for consistent page layout.
///
/// This widget provides a pre-configured Scaffold with AppBar styling
/// and common functionality used throughout the application.
library;

import 'package:flutter/material.dart';

/// A standardized scaffold widget for application pages.
///
/// Wraps the Flutter [Scaffold] with consistent AppBar styling,
/// back button handling, and SafeArea for body content.
///
/// Example usage:
/// ```dart
/// // Basic page with title
/// AppScaffold(
///   title: 'Settings',
///   body: SettingsContent(),
/// )
///
/// // Page with actions and FAB
/// AppScaffold(
///   title: 'Dashboard',
///   actions: [
///     IconButton(
///       icon: Icon(Icons.notifications),
///       onPressed: () => showNotifications(),
///     ),
///   ],
///   floatingActionButton: FloatingActionButton(
///     onPressed: () => createNew(),
///     child: Icon(Icons.add),
///   ),
///   body: DashboardContent(),
/// )
///
/// // Custom back behavior
/// AppScaffold(
///   title: 'Edit Profile',
///   onBackPressed: () => showDiscardDialog(),
///   body: ProfileEditForm(),
/// )
/// ```
class AppScaffold extends StatelessWidget {
  /// Creates an application scaffold widget.
  ///
  /// The [body] parameter is required and contains the main content.
  /// The [title] is displayed in the AppBar when provided.
  /// The [showBackButton] controls back button visibility (default true).
  /// The [onBackPressed] provides custom back navigation behavior.
  const AppScaffold({
    required this.body,
    super.key,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackButton = true,
    this.onBackPressed,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  /// The main content of the scaffold.
  ///
  /// This widget is wrapped in a [SafeArea] for proper inset handling.
  final Widget body;

  /// Optional title displayed in the AppBar.
  ///
  /// When null, no title is shown in the AppBar.
  final String? title;

  /// Optional list of action widgets for the AppBar.
  ///
  /// Typically contains [IconButton] widgets for common actions.
  final List<Widget>? actions;

  /// Optional floating action button for the scaffold.
  final Widget? floatingActionButton;

  /// Optional bottom navigation bar widget.
  final Widget? bottomNavigationBar;

  /// Whether to show the back button in the AppBar.
  ///
  /// Defaults to true. Set to false for root/home pages.
  final bool showBackButton;

  /// Custom callback for back button press.
  ///
  /// When null, uses the default [Navigator.pop] behavior.
  /// Use this for custom navigation or confirmation dialogs.
  final VoidCallback? onBackPressed;

  /// Whether the body should resize when the keyboard appears.
  ///
  /// Defaults to true. Set to false for pages with fixed layouts
  /// that shouldn't scroll when the keyboard opens.
  final bool resizeToAvoidBottomInset;

  /// Optional background color override.
  ///
  /// When null, uses the theme's scaffold background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: _buildAppBar(context, theme, canPop),
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  /// Builds the AppBar with consistent styling.
  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    ThemeData theme,
    bool canPop,
  ) {
    // Only show AppBar if there's a title, actions, or back button needed
    final shouldShowBackButton = showBackButton && canPop;
    final hasContent = title != null || actions != null || shouldShowBackButton;

    if (!hasContent) {
      return null;
    }

    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: shouldShowBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      actions: actions,
    );
  }
}
