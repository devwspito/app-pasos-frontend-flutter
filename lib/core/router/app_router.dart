/// Application router configuration using GoRouter.
///
/// This file defines the navigation structure for the entire application
/// using GoRouter for declarative routing.
library;

import 'package:app_pasos_frontend/core/constants/app_constants.dart';
import 'package:app_pasos_frontend/core/di/injection_container.dart';
import 'package:app_pasos_frontend/core/router/route_names.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_pasos_frontend/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app_pasos_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:app_pasos_frontend/features/auth/presentation/pages/register_page.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/create_goal_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goals_list_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goals_list_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/pages/create_goal_page.dart';
import 'package:app_pasos_frontend/features/goals/presentation/pages/goal_detail_page.dart';
import 'package:app_pasos_frontend/features/goals/presentation/pages/goal_rankings_page.dart';
import 'package:app_pasos_frontend/features/goals/presentation/pages/goals_list_page.dart';
import 'package:app_pasos_frontend/features/goals/presentation/pages/invite_members_page.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/friend_search_bloc.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_bloc.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_event.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/pages/add_friend_page.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/pages/friend_activity_page.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/pages/friend_requests_page.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/pages/friends_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Main application router configuration.
///
/// Provides a configured [GoRouter] instance with all application routes.
/// The router uses the [RouteNames] constants for path definitions.
///
/// Example usage in MaterialApp:
/// ```dart
/// MaterialApp.router(
///   routerConfig: AppRouter.router,
/// )
/// ```
abstract final class AppRouter {
  /// The main GoRouter instance for the application.
  ///
  /// This router is configured with:
  /// - Initial location set to home route
  /// - All application routes defined
  /// - Error page builder for unknown routes
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    routes: _routes,
    errorBuilder: _errorBuilder,
  );

  /// List of all application routes.
  static final List<RouteBase> _routes = [
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) => const FoundationReadyScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.register,
      name: 'register',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.dashboard,
      name: 'dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<DashboardBloc>()..add(const DashboardLoadRequested()),
        child: const DashboardPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.profile,
      name: 'profile',
      builder: (context, state) => const _PlaceholderScreen(
        routeName: 'Profile',
        icon: Icons.person,
      ),
    ),
    GoRoute(
      path: RouteNames.settings,
      name: 'settings',
      builder: (context, state) => const _PlaceholderScreen(
        routeName: 'Settings',
        icon: Icons.settings,
      ),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const ForgotPasswordPage(),
      ),
    ),
    // ============================================================
    // Sharing/Friends Routes
    // ============================================================
    GoRoute(
      path: RouteNames.friends,
      name: 'friends',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SharingBloc>()..add(const SharingLoadRequested()),
        child: const FriendsListPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.friendRequests,
      name: 'friendRequests',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SharingBloc>()..add(const SharingLoadRequested()),
        child: const FriendRequestsPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.friendActivity,
      name: 'friendActivity',
      builder: (context, state) {
        final friendId = state.uri.queryParameters['friendId'] ?? '';
        return FriendActivityPage(friendId: friendId);
      },
    ),
    GoRoute(
      path: RouteNames.addFriend,
      name: 'addFriend',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<FriendSearchBloc>(),
          ),
          BlocProvider(
            create: (_) => sl<SharingBloc>(),
          ),
        ],
        child: const AddFriendPage(),
      ),
    ),
    // ============================================================
    // Goals Routes
    // ============================================================
    GoRoute(
      path: RouteNames.goals,
      name: 'goals',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<GoalsListBloc>()..add(const GoalsListLoadRequested()),
        child: const GoalsListPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.goalDetail,
      name: 'goalDetail',
      builder: (context, state) {
        final goalId = state.uri.queryParameters['goalId'] ?? '';
        return BlocProvider(
          create: (_) => sl<GoalDetailBloc>()
            ..add(GoalDetailLoadRequested(goalId: goalId)),
          child: GoalDetailPage(goalId: goalId),
        );
      },
    ),
    GoRoute(
      path: RouteNames.createGoal,
      name: 'createGoal',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<CreateGoalBloc>(),
        child: const CreateGoalPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.inviteMembers,
      name: 'inviteMembers',
      builder: (context, state) {
        final goalId = state.uri.queryParameters['goalId'] ?? '';
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => sl<FriendSearchBloc>(),
            ),
            BlocProvider(
              create: (_) => sl<GoalDetailBloc>(),
            ),
          ],
          child: InviteMembersPage(goalId: goalId),
        );
      },
    ),
    GoRoute(
      path: RouteNames.goalRankings,
      name: 'goalRankings',
      builder: (context, state) {
        final goalId = state.uri.queryParameters['goalId'] ?? '';
        return BlocProvider(
          create: (_) => sl<GoalDetailBloc>()
            ..add(GoalDetailLoadRequested(goalId: goalId)),
          child: GoalRankingsPage(goalId: goalId),
        );
      },
    ),
  ];

  /// Builds the error page for unknown routes.
  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return _ErrorScreen(error: state.error?.toString() ?? 'Page not found');
  }
}

/// Placeholder screen for routes not yet implemented.
///
/// This widget displays a simple placeholder UI with the route name
/// and an icon. It will be replaced with actual screens in future stories.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.routeName,
    required this.icon,
  });

  final String routeName;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              routeName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Route: ${_getRoutePath(routeName)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the route path from the route name.
  static String _getRoutePath(String routeName) {
    switch (routeName) {
      case 'Home':
        return RouteNames.home;
      case 'Login':
        return RouteNames.login;
      case 'Register':
        return RouteNames.register;
      case 'Dashboard':
        return RouteNames.dashboard;
      case 'Profile':
        return RouteNames.profile;
      case 'Settings':
        return RouteNames.settings;
      case 'ForgotPassword':
        return RouteNames.forgotPassword;
      default:
        return '/unknown';
    }
  }
}

/// Home screen indicating the foundation is ready.
///
/// This screen displays a confirmation that the app foundation is properly
/// set up with dependency injection and core services.
class FoundationReadyScreen extends StatelessWidget {
  /// Creates the Foundation Ready screen.
  const FoundationReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'App Pasos',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Foundation Ready',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Dependency injection initialized\n'
                'Core services registered\n'
                'GoRouter navigation configured',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error screen displayed when navigation fails.
///
/// This screen is shown when the router cannot find a matching route
/// or when a navigation error occurs.
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(RouteNames.home),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
