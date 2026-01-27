/// Root application widget for App Pasos.
///
/// This file defines the main [App] widget which configures the
/// [MaterialApp.router] with theming, routing, and global settings.
library;

import 'package:app_pasos_frontend/core/constants/app_constants.dart';
import 'package:app_pasos_frontend/core/router/app_router.dart';
import 'package:app_pasos_frontend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The root widget of the App Pasos application.
///
/// This widget configures:
/// - Material 3 theming with custom [AppTheme]
/// - GoRouter navigation with [AppRouter]
/// - App title from [AppConstants]
/// - Debug banner visibility
///
/// This widget should be created after dependency injection is initialized
/// and passed to `runApp` in `main.dart`.
///
/// Example usage:
/// ```dart
/// await initializeDependencies();
/// runApp(const App());
/// ```
class App extends StatelessWidget {
  /// Creates the root [App] widget.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Application title shown in task switcher
      title: AppConstants.appName,

      // Hide debug banner in debug mode
      debugShowCheckedModeBanner: false,

      // Custom theme from AppTheme
      theme: AppTheme.lightTheme,

      // Dark theme from AppTheme
      darkTheme: AppTheme.darkTheme,

      // GoRouter configuration
      routerConfig: AppRouter.router,
    );
  }
}
