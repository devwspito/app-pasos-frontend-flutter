/// Root application widget for App Pasos.
///
/// This file defines the main [App] widget which configures the
/// [MaterialApp] with theming, routing, and global settings.
library;

import 'package:app_pasos_frontend/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// The root widget of the App Pasos application.
///
/// This widget configures:
/// - Material 3 theming with blue color scheme
/// - App title from [AppConstants]
/// - Debug banner visibility
/// - Home screen (placeholder until navigation is set up)
///
/// This widget should be created after dependency injection is initialized
/// and passed to [runApp] in [main.dart].
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
    return MaterialApp(
      // Application title shown in task switcher
      title: AppConstants.appName,

      // Hide debug banner in debug mode
      debugShowCheckedModeBanner: false,

      // Material 3 theme configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // Dark theme configuration (optional, for future implementation)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Placeholder home screen - will be replaced with proper routing
      home: const _FoundationReadyScreen(),
    );
  }
}

/// Temporary home screen indicating the foundation is ready.
///
/// This screen will be replaced with proper routing and the actual
/// home screen when the navigation feature is implemented.
class _FoundationReadyScreen extends StatelessWidget {
  const _FoundationReadyScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'App Pasos',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Foundation Ready',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Dependency injection initialized\n'
                'Core services registered\n'
                'Environment configured',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
