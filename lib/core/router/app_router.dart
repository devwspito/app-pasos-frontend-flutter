import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../constants/app_constants.dart';

/// Route name constants to avoid hardcoding strings in screens.
///
/// Usage: `context.goNamed(AppRoutes.dashboard)`
abstract class AppRoutes {
  /// Dashboard route name (home screen).
  static const String dashboard = 'dashboard';

  /// Step history route name.
  static const String history = 'history';

  /// Login route name.
  static const String login = 'login';

  /// Register route name.
  static const String register = 'register';
}

/// Centralized router configuration for the app.
///
/// Provides a static [router] getter that returns the configured [GoRouter].
/// Use [AppRoutes] constants for route names instead of hardcoded strings.
class AppRouter {
  AppRouter._();

  /// The application's router configuration.
  ///
  /// Routes:
  /// - `/` → DashboardScreen (home)
  /// - `/history` → StepHistoryScreen
  /// - `/login` → LoginScreen
  /// - `/register` → RegisterScreen
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.dashboard,
        builder: (context, state) => const _DashboardPlaceholder(),
      ),
      GoRoute(
        path: '/history',
        name: AppRoutes.history,
        builder: (context, state) => const _StepHistoryPlaceholder(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(
      path: state.uri.path,
    ),
  );
}

/// Placeholder screen for Dashboard until actual implementation.
///
/// TODO: Replace with actual DashboardScreen when implemented.
class _DashboardPlaceholder extends StatelessWidget {
  const _DashboardPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Step History',
            onPressed: () => context.goNamed(AppRoutes.history),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'v${AppConstants.appVersion}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Dashboard coming soon!\nTrack your daily steps here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.goNamed(AppRoutes.history),
                icon: const Icon(Icons.history),
                label: const Text('View Step History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder screen for Step History until actual implementation.
///
/// TODO: Replace with actual StepHistoryScreen when implemented.
class _StepHistoryPlaceholder extends StatelessWidget {
  const _StepHistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRoutes.dashboard),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Step History',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your step history will appear here.\nComing soon!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error screen shown when a route is not found.
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The page "$path" could not be found.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.goNamed(AppRoutes.dashboard),
                icon: const Icon(Icons.home),
                label: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
