/// Entry point for the App Pasos application.
///
/// This file initializes the application by:
/// 1. Ensuring Flutter bindings are ready
/// 2. Loading environment variables from .env file
/// 3. Initializing dependency injection
/// 4. Running the main App widget
///
/// ## Shared Widgets Exports
///
/// For importing shared widgets throughout the application, use:
/// ```dart
/// import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
/// import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
/// import 'package:app_pasos_frontend/shared/widgets/empty_state.dart';
/// import 'package:app_pasos_frontend/shared/widgets/app_scaffold.dart';
/// ```
///
/// Available widgets:
/// - `LoadingIndicator` - Circular progress with optional message and overlay
/// - `AppErrorWidget` - Error display with retry functionality
/// - `EmptyState` - Empty content display with optional action
/// - `AppScaffold` - Consistent page layout with AppBar
library;

import 'package:app_pasos_frontend/app.dart';
import 'package:app_pasos_frontend/core/di/injection_container.dart';
import 'package:app_pasos_frontend/core/services/background_sync_service.dart';
import 'package:app_pasos_frontend/core/services/notification_handler.dart';
import 'package:app_pasos_frontend/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application entry point.
///
/// This function is called when the app starts. It performs the following
/// initialization steps in order:
///
/// 1. [WidgetsFlutterBinding.ensureInitialized] - Required for async operations
///    before runApp, such as loading files or initializing plugins.
///
/// 2. `dotenv.load` - Loads environment variables from the .env file.
///    If the file doesn't exist, the app continues with default values.
///
/// 3. [initializeDependencies] - Registers all services in the DI container.
///    This must complete before the app runs to ensure services are available.
///
/// 4. [runApp] - Starts the Flutter application with the [App] widget.
///
/// Example .env file:
/// ```
/// API_BASE_URL=http://localhost:3000/api
/// ENV=development
/// ```
Future<void> main() async {
  // Ensure Flutter bindings are initialized before any async operations.
  // This is required for plugins and platform channels to work properly.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file.
  // Using mergeWith: {} ensures the app doesn't crash if .env is missing.
  // In production, variables can come from platform-specific config.
  await dotenv.load().catchError((_) {
    // .env file not found - continue with defaults
    // This is expected in production where env vars come from the platform
    debugPrint('No .env file found, using default configuration');
  });

  // Initialize all application dependencies.
  // This registers services like ApiClient, SecureStorage, etc.
  // Services are registered as lazy singletons for efficiency.
  await initializeDependencies();

  // Initialize background sync service.
  // This sets up the workmanager and registers background task handlers.
  await sl<BackgroundSyncService>().initialize();

  // Start background sync with 1-hour interval.
  // This enables periodic synchronization of health data even when the app
  // is in the background or terminated.
  await sl<BackgroundSyncService>().startPeriodicSync(
    interval: const Duration(hours: 1),
  );

  // Initialize notification service.
  // This sets up Firebase Messaging and registers for notifications.
  await sl<NotificationService>().initialize();

  // Request notification permission.
  await sl<NotificationService>().requestPermission();

  // Initialize notification handler for deep linking.
  await sl<NotificationHandler>().initialize();

  // Start the application.
  runApp(const App());
}
