import 'package:app_pasos/core/config/app_config.dart';
import 'package:app_pasos/core/config/environment.dart';
import 'package:app_pasos/core/di/service_locator.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  AppConfig.instance.init(Environment.development);

  // Setup dependency injection
  await setupServiceLocator();

  runApp(const AppPasosApp());
}

/// Root widget of the App Pasos application.
///
/// Configures Material 3 theming and routing.
class AppPasosApp extends StatelessWidget {
  /// Creates the root application widget.
  const AppPasosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Pasos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _PlaceholderHomeScreen(),
    );
  }
}

/// Temporary home screen - will be replaced by routing epic.
///
/// Displays a simple confirmation that foundation setup is complete.
class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Pasos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk, size: 64),
            SizedBox(height: 16),
            Text(
              'Foundation Setup Complete',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Core dependencies initialized'),
          ],
        ),
      ),
    );
  }
}
