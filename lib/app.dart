/// Root application widget for App Pasos.
///
/// This file defines the main [App] widget which configures the
/// [MaterialApp.router] with theming, routing, and global settings.
/// It also manages WebSocket connection lifecycle.
library;

import 'package:app_pasos_frontend/core/constants/app_constants.dart';
import 'package:app_pasos_frontend/core/di/injection_container.dart';
import 'package:app_pasos_frontend/core/router/app_router.dart';
import 'package:app_pasos_frontend/core/services/websocket_event_handler.dart';
import 'package:app_pasos_frontend/core/services/websocket_service.dart';
import 'package:app_pasos_frontend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The root widget of the App Pasos application.
///
/// This widget configures:
/// - Material 3 theming with custom [AppTheme]
/// - GoRouter navigation with [AppRouter]
/// - App title from [AppConstants]
/// - Debug banner visibility
/// - WebSocket connection lifecycle management
///
/// This widget should be created after dependency injection is initialized
/// and passed to `runApp` in `main.dart`.
///
/// Example usage:
/// ```dart
/// await initializeDependencies();
/// runApp(const App());
/// ```
class App extends StatefulWidget {
  /// Creates the root [App] widget.
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// WebSocket service for real-time communication.
  late final WebSocketService _webSocketService;

  /// WebSocket event handler for routing messages to BLoCs.
  late final WebSocketEventHandler _webSocketEventHandler;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  /// Initializes WebSocket connection asynchronously.
  ///
  /// This method gets the WebSocket services from DI and initiates
  /// the connection. Connection is non-blocking to avoid delaying
  /// app startup. Errors are caught to prevent app crashes.
  void _initializeWebSocket() {
    _webSocketService = sl<WebSocketService>();
    _webSocketEventHandler = sl<WebSocketEventHandler>();

    // Connect WebSocket asynchronously - don't block app startup
    // ignore: discarded_futures
    _webSocketService.connect().catchError((Object error) {
      // Log error but don't crash the app
      debugPrint('WebSocket connection failed: $error');
    });
  }

  @override
  void dispose() {
    // Disconnect WebSocket when app is disposed
    _webSocketService.disconnect();
    super.dispose();
  }

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
