import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/environment.dart';
import 'routes.dart';

/// Creates and configures the application's router.
///
/// The router is configured with:
/// - Debug logging in development mode
/// - Initial location set to splash screen
/// - All main application routes
///
/// Usage:
/// ```dart
/// final router = createAppRouter();
/// MaterialApp.router(routerConfig: router);
/// ```
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: Environment.isDevelopment,
    routes: _buildRoutes(),
    errorBuilder: _errorBuilder,
  );
}

/// Builds the list of application routes.
List<RouteBase> _buildRoutes() {
  return [
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (context, state) => const _PlaceholderScreen(title: 'Splash'),
    ),
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
    ),
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
    ),
    GoRoute(
      path: Routes.register,
      name: 'register',
      builder: (context, state) => const _PlaceholderScreen(title: 'Register'),
    ),
    GoRoute(
      path: Routes.profile,
      name: 'profile',
      builder: (context, state) => const _PlaceholderScreen(title: 'Profile'),
    ),
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      builder: (context, state) => const _PlaceholderScreen(title: 'Settings'),
    ),
  ];
}

/// Error page builder for unknown routes.
Widget _errorBuilder(BuildContext context, GoRouterState state) {
  return Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Route not found: ${state.uri.path}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(Routes.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  );
}

/// Placeholder screen used during development.
///
/// This widget will be replaced with actual screens as they are implemented.
/// It provides a simple visual indicator of which route is active.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
