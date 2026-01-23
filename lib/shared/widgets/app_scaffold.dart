import 'package:flutter/material.dart';

/// Enum representing the type of AppBar to display.
enum AppBarType {
  /// Standard AppBar with title and optional actions.
  standard,

  /// Large AppBar with collapsing title.
  large,

  /// No AppBar.
  none,
}

/// A reusable scaffold widget that wraps [Scaffold] with [SafeArea]
/// and provides consistent layout structure across the app.
///
/// Features:
/// - Optional AppBar with customizable title and actions
/// - SafeArea wrapping for proper device padding
/// - Floating Action Button support
/// - Bottom navigation support
/// - Drawer support
///
/// Usage:
/// ```dart
/// AppScaffold(
///   title: 'Home',
///   body: HomeContent(),
///   floatingActionButton: FloatingActionButton(
///     onPressed: () {},
///     child: Icon(Icons.add),
///   ),
/// )
/// ```
class AppScaffold extends StatelessWidget {
  /// Creates an [AppScaffold] widget.
  ///
  /// The [body] parameter is required and represents the main content.
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.appBarType = AppBarType.standard,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.useSafeArea = true,
  });

  /// The main content of the scaffold.
  final Widget body;

  /// The title displayed in the AppBar.
  /// Ignored if [titleWidget] is provided or [appBarType] is [AppBarType.none].
  final String? title;

  /// Custom title widget for the AppBar.
  /// Takes precedence over [title].
  final Widget? titleWidget;

  /// The type of AppBar to display.
  /// Defaults to [AppBarType.standard].
  final AppBarType appBarType;

  /// Leading widget in the AppBar (typically a back button or drawer icon).
  final Widget? leading;

  /// Action widgets displayed in the AppBar.
  final List<Widget>? actions;

  /// Floating action button displayed on the scaffold.
  final Widget? floatingActionButton;

  /// Location of the floating action button.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Bottom navigation bar widget.
  final Widget? bottomNavigationBar;

  /// Drawer widget for the scaffold.
  final Widget? drawer;

  /// End drawer widget for the scaffold.
  final Widget? endDrawer;

  /// Background color of the scaffold.
  /// Defaults to theme's surface color.
  final Color? backgroundColor;

  /// Whether the body should resize when the keyboard appears.
  /// Defaults to true.
  final bool resizeToAvoidBottomInset;

  /// Whether the body extends behind the bottom navigation bar.
  final bool extendBody;

  /// Whether the body extends behind the app bar.
  final bool extendBodyBehindAppBar;

  /// Whether to wrap the body in a [SafeArea].
  /// Defaults to true.
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: useSafeArea ? SafeArea(child: body) : body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  /// Builds the AppBar based on [appBarType].
  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (appBarType == AppBarType.none) {
      return null;
    }

    final effectiveTitle = titleWidget ?? (title != null ? Text(title!) : null);

    if (appBarType == AppBarType.large) {
      return SliverAppBar.large(
        title: effectiveTitle,
        leading: leading,
        actions: actions,
        floating: true,
        pinned: true,
      );
    }

    return AppBar(
      title: effectiveTitle,
      leading: leading,
      actions: actions,
    );
  }
}

/// Extension to create AppScaffold with SliverAppBar for scrollable content.
class AppScaffoldWithSliver extends StatelessWidget {
  /// Creates an [AppScaffoldWithSliver] widget.
  const AppScaffoldWithSliver({
    super.key,
    required this.slivers,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.expandedHeight = 200.0,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.flexibleSpace,
  });

  /// The slivers to display in the scroll view.
  final List<Widget> slivers;

  /// The title displayed in the AppBar.
  final String? title;

  /// Custom title widget for the AppBar.
  final Widget? titleWidget;

  /// Leading widget in the AppBar.
  final Widget? leading;

  /// Action widgets displayed in the AppBar.
  final List<Widget>? actions;

  /// Floating action button displayed on the scaffold.
  final Widget? floatingActionButton;

  /// Location of the floating action button.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Bottom navigation bar widget.
  final Widget? bottomNavigationBar;

  /// Drawer widget for the scaffold.
  final Widget? drawer;

  /// End drawer widget for the scaffold.
  final Widget? endDrawer;

  /// Background color of the scaffold.
  final Color? backgroundColor;

  /// The height of the app bar when expanded.
  final double expandedHeight;

  /// Whether the app bar should remain visible at the top.
  final bool pinned;

  /// Whether the app bar should float.
  final bool floating;

  /// Whether the app bar should snap into view.
  final bool snap;

  /// Flexible space widget for the app bar.
  final Widget? flexibleSpace;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveTitle = titleWidget ?? (title != null ? Text(title!) : null);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: effectiveTitle,
            leading: leading,
            actions: actions,
            expandedHeight: expandedHeight,
            pinned: pinned,
            floating: floating,
            snap: snap,
            flexibleSpace: flexibleSpace,
          ),
          ...slivers,
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor ?? colorScheme.surface,
    );
  }
}
