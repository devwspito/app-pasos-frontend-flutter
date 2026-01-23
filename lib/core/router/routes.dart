/// Route path constants for the application.
///
/// Use these constants instead of hardcoding route strings in widgets:
/// ```dart
/// context.go(Routes.home);
/// context.push(Routes.login);
/// ```
///
/// This ensures type-safe navigation and makes route changes easier.
abstract final class Routes {
  /// Splash screen route - initial route on app launch.
  static const String splash = '/splash';

  /// Home screen route - main app screen after authentication.
  static const String home = '/';

  /// Login screen route - for user authentication.
  static const String login = '/login';

  /// Registration screen route - for new user sign up.
  static const String register = '/register';

  /// User profile screen route.
  static const String profile = '/profile';

  /// Settings screen route.
  static const String settings = '/settings';
}
