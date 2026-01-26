import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

/// Static route path constants to avoid hardcoding paths.
///
/// Use these constants throughout the app for navigation:
/// ```dart
/// context.go(AppRoutes.login);
/// ```
class AppRoutes {
  /// Login screen route.
  static const String login = '/login';

  /// Registration screen route.
  static const String register = '/register';

  /// Forgot password screen route.
  static const String forgotPassword = '/forgot-password';

  /// Home screen route (main app content).
  static const String home = '/home';

  /// Splash/loading screen route.
  static const String splash = '/splash';

  /// Profile settings screen route.
  static const String profile = '/profile';

  /// Prevent instantiation.
  AppRoutes._();
}

/// Main application router using GoRouter.
///
/// Handles:
/// - Route definitions and navigation
/// - Authentication-based redirects (guards)
/// - Deep linking support
///
/// Usage:
/// ```dart
/// final appRouter = AppRouter(authProvider: authProvider);
///
/// MaterialApp.router(
///   routerConfig: appRouter.router,
/// )
/// ```
///
/// The router automatically redirects:
/// - Unauthenticated users to login when accessing protected routes
/// - Authenticated users away from auth screens to home
class AppRouter {
  /// The authentication provider for checking auth state.
  final AuthProvider authProvider;

  /// The configured GoRouter instance.
  late final GoRouter router;

  /// Creates a new AppRouter with the given [authProvider].
  ///
  /// The router is configured immediately upon construction.
  AppRouter({required this.authProvider}) {
    router = GoRouter(
      // Listen to auth changes to trigger route refresh
      refreshListenable: authProvider,

      // Initial route when app starts
      initialLocation: AppRoutes.splash,

      // Global redirect handler for auth guards
      redirect: _handleRedirect,

      // Error page handler
      errorBuilder: (context, state) => _ErrorPage(
        error: state.error?.toString() ?? 'Page not found',
      ),

      // Route definitions
      routes: [
        // Splash/loading screen
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const _SplashPage(),
        ),

        // Login screen
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const _AuthPlaceholderPage(
            title: 'Login',
            routeName: AppRoutes.login,
          ),
          // TODO: Replace with actual LoginPage when created
          // builder: (context, state) => const LoginPage(),
        ),

        // Registration screen
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const _AuthPlaceholderPage(
            title: 'Create Account',
            routeName: AppRoutes.register,
          ),
          // TODO: Replace with actual RegisterPage when created
          // builder: (context, state) => const RegisterPage(),
        ),

        // Forgot password screen
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgot-password',
          builder: (context, state) => const _AuthPlaceholderPage(
            title: 'Reset Password',
            routeName: AppRoutes.forgotPassword,
          ),
          // TODO: Replace with actual ForgotPasswordPage when created
          // builder: (context, state) => const ForgotPasswordPage(),
        ),

        // Home screen (main app content)
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const _HomePlaceholderPage(),
          // TODO: Replace with actual HomePage when created
          // builder: (context, state) => const HomePage(),
        ),

        // Profile screen
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const _ProfilePlaceholderPage(),
          // TODO: Replace with actual ProfilePage when created
          // builder: (context, state) => const ProfilePage(),
        ),
      ],
    );
  }

  /// Handles authentication-based redirects.
  ///
  /// Logic:
  /// 1. If auth status is initial/loading → stay on splash
  /// 2. If authenticated and on auth pages → redirect to home
  /// 3. If unauthenticated and on protected pages → redirect to login
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authStatus = authProvider.status;
    final currentPath = state.matchedLocation;

    // Define auth pages (no auth required)
    const authPages = [
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
    ];

    // Check if on splash page
    final isOnSplash = currentPath == AppRoutes.splash;

    // Check if on an auth page
    final isOnAuthPage = authPages.contains(currentPath);

    // While checking auth status, keep on splash
    if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
      if (!isOnSplash) {
        return AppRoutes.splash;
      }
      return null; // Stay on splash
    }

    // If authenticated
    if (authProvider.isAuthenticated) {
      // Redirect away from splash and auth pages
      if (isOnSplash || isOnAuthPage) {
        return AppRoutes.home;
      }
      return null; // Allow access to other pages
    }

    // If not authenticated
    if (!authProvider.isAuthenticated) {
      // Allow access to auth pages
      if (isOnAuthPage) {
        return null;
      }
      // Redirect from protected pages and splash to login
      return AppRoutes.login;
    }

    return null;
  }
}

/// Splash page shown while checking authentication status.
///
/// Displays a loading indicator while the app determines
/// if the user has a valid session.
class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo placeholder
            Icon(
              Icons.directions_walk_rounded,
              size: 80,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'AppPasos',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder page for authentication screens.
///
/// This will be replaced with actual authentication screens
/// when they are implemented by Epic 4 (Auth UI).
class _AuthPlaceholderPage extends StatefulWidget {
  final String title;
  final String routeName;

  const _AuthPlaceholderPage({
    required this.title,
    required this.routeName,
  });

  @override
  State<_AuthPlaceholderPage> createState() => _AuthPlaceholderPageState();
}

class _AuthPlaceholderPageState extends State<_AuthPlaceholderPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Route: ${widget.routeName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Placeholder: ${widget.title} form submitted. '
                            'Actual implementation pending.',
                          ),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(widget.title),
                ),
                const SizedBox(height: 16),

                // Navigation links
                if (widget.routeName == AppRoutes.login) ...[
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: const Text("Don't have an account? Register"),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.forgotPassword),
                    child: const Text('Forgot Password?'),
                  ),
                ] else if (widget.routeName == AppRoutes.register) ...[
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Already have an account? Login'),
                  ),
                ] else if (widget.routeName == AppRoutes.forgotPassword) ...[
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Back to Login'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder for the home page.
///
/// Will be replaced with actual home page implementation.
class _HomePlaceholderPage extends StatelessWidget {
  const _HomePlaceholderPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go(AppRoutes.profile),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to AppPasos',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You are authenticated!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Route: ${AppRoutes.home}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Main app content will be displayed here.\n'
                  'This placeholder will be replaced when the\n'
                  'home feature is implemented.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          // Navigation will be implemented with actual screens
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Placeholder for the profile page.
class _ProfilePlaceholderPage extends StatelessWidget {
  const _ProfilePlaceholderPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'User Profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Route: ${AppRoutes.profile}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Profile options
              _ProfileOption(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {},
              ),
              _ProfileOption(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {},
              ),
              _ProfileOption(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                onTap: () {},
              ),
              _ProfileOption(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // Logout button
              OutlinedButton.icon(
                onPressed: () {
                  // This will trigger AuthProvider.logout() and redirect
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout will be connected to AuthProvider'),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile option list tile.
class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Error page shown when a route is not found.
class _ErrorPage extends StatelessWidget {
  final String error;

  const _ErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
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
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home),
                  label: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
