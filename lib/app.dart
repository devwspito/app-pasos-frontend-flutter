import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';

/// Root application widget.
///
/// This widget configures the MaterialApp with:
/// - GoRouter for declarative routing (retrieved from DI)
/// - Material 3 theming
/// - Debug banner disabled
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
