import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart';

/// Application entry point.
///
/// Initializes the Flutter binding, configures all dependencies via
/// the service locator, and launches the root [App] widget.
///
/// The initialization sequence is:
/// 1. [WidgetsFlutterBinding.ensureInitialized] - Required for async operations
/// 2. [configureDependencies] - Register all DI dependencies
/// 3. [runApp] - Launch the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const App());
}
