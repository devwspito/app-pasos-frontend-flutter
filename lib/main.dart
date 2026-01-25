import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';

/// Application entry point for App Pasos.
///
/// This is the main function that initializes the Flutter application.
/// It ensures Flutter bindings are initialized, loads environment variables
/// from the `.env` file, and then runs the App widget.
///
/// **Initialization sequence:**
/// 1. Initialize Flutter bindings (required for async operations before runApp)
/// 2. Load environment variables from `.env` file
/// 3. Run the application
///
/// Example .env file:
/// ```
/// API_BASE_URL=https://api.apppasos.com
/// ENVIRONMENT=production
/// DEBUG_MODE=false
/// ```
///
/// **IMPORTANT:** Ensure `.env` is listed in pubspec.yaml assets:
/// ```yaml
/// flutter:
///   assets:
///     - .env
/// ```
void main() async {
  // Ensure Flutter bindings are initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  // TODO: Add logger.info() once logging service is set up
  await dotenv.load(fileName: '.env');

  // Run the application
  runApp(const App());
}
