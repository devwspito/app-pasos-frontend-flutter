/// Splash page widget for App Pasos.
///
/// This page displays the application branding while checking authentication
/// status and navigating to the appropriate screen (dashboard or login).
library;

import 'package:app_pasos_frontend/core/constants/app_constants.dart';
import 'package:app_pasos_frontend/core/di/injection_container.dart';
import 'package:app_pasos_frontend/core/router/route_names.dart';
import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash screen displayed on app launch.
///
/// Shows the app branding (icon and name) while checking if the user
/// is authenticated. After a minimum splash duration for branding,
/// navigates to either:
/// - [RouteNames.dashboard] if authenticated
/// - [RouteNames.login] if not authenticated
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: '/',
///   builder: (context, state) => const SplashPage(),
/// ),
/// ```
class SplashPage extends StatefulWidget {
  /// Creates a splash page widget.
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

  /// Checks authentication status and navigates to the appropriate screen.
  ///
  /// Waits for a minimum splash duration (1.5 seconds) for branding visibility,
  /// then checks if the user is authenticated via [SecureStorageService].
  /// Navigates to dashboard if authenticated, otherwise to login.
  Future<void> _checkAuthAndNavigate() async {
    // Minimum splash duration for branding visibility
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // Check if widget is still mounted before proceeding
    if (!mounted) return;

    // Check authentication status using the DI service locator
    final storageService = sl<SecureStorageService>();
    final isAuthenticated = await storageService.isAuthenticated();

    // Verify mounted state again after async operation
    if (!mounted) return;

    // Navigate based on authentication status
    if (isAuthenticated) {
      context.go(RouteNames.dashboard);
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Icon(
                Icons.directions_walk,
                size: 120,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // App name
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const LoadingIndicator(
                message: 'Cargando...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
