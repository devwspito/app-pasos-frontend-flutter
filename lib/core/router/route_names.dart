/// Route name constants for the application.
///
/// This file defines all route paths used in the application's navigation.
/// Using constants ensures consistency and prevents typos in route paths.
library;

/// Route path constants for application navigation.
///
/// All route paths should be defined here and used throughout the application
/// instead of string literals. This enables:
/// - Compile-time checking for route references
/// - Easy refactoring of route paths
/// - Consistent naming across the codebase
///
/// Example usage:
/// ```dart
/// context.go(RouteNames.dashboard);
/// context.push(RouteNames.profile);
/// ```
abstract final class RouteNames {
  /// Home route - displays the Foundation Ready screen.
  ///
  /// This is the initial route when the app launches.
  static const String home = '/';

  /// Login route - user authentication screen.
  static const String login = '/login';

  /// Register route - new user registration screen.
  static const String register = '/register';

  /// Dashboard route - main user dashboard.
  static const String dashboard = '/dashboard';

  /// Profile route - user profile screen.
  static const String profile = '/profile';

  /// Settings route - application settings screen.
  static const String settings = '/settings';

  /// Forgot Password route - password recovery screen.
  static const String forgotPassword = '/forgot-password';

  // ============================================================
  // Sharing/Friends Routes
  // ============================================================

  /// Friends list route - displays the user's friends.
  static const String friends = '/friends';

  /// Friend requests route - displays pending friend requests.
  static const String friendRequests = '/friends/requests';

  /// Friend activity route - displays a friend's step statistics.
  static const String friendActivity = '/friends/activity';

  /// Add friend route - search and add new friends.
  static const String addFriend = '/friends/add';
}
