import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';

/// Root application widget.
///
/// This widget configures the MaterialApp with:
/// - GoRouter for declarative routing (retrieved from DI)
/// - Material Design 3 theming with light/dark mode support
/// - System theme mode for automatic light/dark switching
/// - Debug banner disabled
///
/// The app uses [AppTheme.lightTheme] and [AppTheme.darkTheme] for
/// consistent styling following Material Design 3 guidelines.
///
/// Usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await configureDependencies();
///   runApp(const App());
/// }
/// ```
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = sl<GoRouter>();

    return MaterialApp.router(
      title: 'Pasos App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
