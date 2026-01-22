import 'package:flutter/material.dart';

import 'core/theme/theme.dart';

void main() {
  runApp(const AppPasosApp());
}

/// Root application widget.
///
/// Configures Material Design 3 theming with light and dark mode support.
class AppPasosApp extends StatelessWidget {
  /// Creates the root application widget.
  const AppPasosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Pasos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('App Pasos'),
        ),
      ),
    );
  }
}
