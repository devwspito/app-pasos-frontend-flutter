/// Splash page for initial app loading and authentication check.
///
/// This page displays the app logo and loading indicator while checking
/// the user's authentication status. It navigates to the appropriate
/// route based on whether the user is authenticated.
library;

import 'package:app_pasos_frontend/core/constants/app_constants.dart';
import 'package:app_pasos_frontend/core/di/injection_container.dart';
import 'package:app_pasos_frontend/core/router/route_names.dart';
import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash page that checks authentication and navigates accordingly.
///
/// Displays the app logo, app name, and a loading indicator while
/// checking if the user has a stored authentication token. Navigates
/// to the dashboard if authenticated, or to the login page otherwise.
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: RouteNames.home,
///   builder: (context, state) => const SplashPage(),
/// )
/// ```
class SplashPage extends StatefulWidget {
  /// Creates a [SplashPage].
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  /// Checks authentication status and navigates to appropriate route.
  ///
  /// Uses [SecureStorageService.isAuthenticated] to check for stored token.
  /// Navigates to dashboard if authenticated, login otherwise.
  /// Includes mounted check to prevent navigation after widget disposal.
  Future<void> _checkAuthAndNavigate() async {
    final storage = sl<SecureStorageService>();
    final isAuthenticated = await storage.isAuthenticated();

    // Check if widget is still mounted before navigating
    if (!mounted) return;

    if (isAuthenticated) {
      context.go(RouteNames.dashboard);
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo icon
              Icon(
                Icons.directions_walk,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // App name
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const LoadingIndicator(message: 'Loading...'),
            ],
          ),
        ),
      ),
    );
  }
}
