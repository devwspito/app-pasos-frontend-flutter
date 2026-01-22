import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/sharing/presentation/screens/add_friend_screen.dart';
import '../../features/sharing/presentation/screens/friend_detail_screen.dart';
import '../../features/sharing/presentation/screens/friends_screen.dart';
import '../constants/app_constants.dart';

/// Application router configuration.
///
/// Centralizes all route definitions for the app.
/// Uses GoRouter for declarative routing with deep linking support.
///
/// Usage:
/// ```dart
/// MaterialApp.router(
///   routerConfig: appRouter,
///   ...
/// )
/// ```
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    // ============================================
    // Home Route
    // ============================================
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Home',
        message: 'App Pasos is ready!\nStart building amazing features.',
        icon: Icons.rocket_launch_outlined,
      ),
    ),

    // ============================================
    // Auth Routes
    // ============================================
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Login',
        message: 'Authentication coming soon.',
        icon: Icons.login,
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Register',
        message: 'Registration coming soon.',
        icon: Icons.person_add_alt_1,
      ),
    ),

    // ============================================
    // Friends/Sharing Routes
    // ============================================
    GoRoute(
      path: '/friends',
      name: 'friends',
      builder: (context, state) => const FriendsScreen(),
      routes: [
        // Add friend route (nested under /friends)
        GoRoute(
          path: 'add',
          name: 'addFriend',
          builder: (context, state) => const AddFriendScreen(),
        ),
        // Friend detail route with ID parameter
        GoRoute(
          path: ':id',
          name: 'friendDetail',
          builder: (context, state) {
            final friendId = state.pathParameters['id']!;
            return FriendDetailScreen(friendId: friendId);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => _PlaceholderScreen(
    title: 'Error',
    message: 'Page not found: ${state.uri.path}',
    icon: Icons.error_outline,
  ),
);

/// Placeholder screen widget used during development.
///
/// Displays a simple centered layout with an icon, title, and message.
/// Used for routes that haven't been fully implemented yet.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.message,
    this.icon = Icons.construction,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
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
                message,
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
