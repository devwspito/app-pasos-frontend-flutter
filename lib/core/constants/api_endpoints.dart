/// API endpoint paths for the application.
///
/// Provides centralized access to all API endpoint paths as static constants.
/// Use with [Environment.apiBaseUrl] to construct full URLs.
abstract final class ApiEndpoints {
  // ============================================================================
  // Authentication Endpoints
  // ============================================================================

  /// Base path for authentication endpoints.
  static const String baseAuth = '/auth';

  /// Login endpoint.
  static const String login = '$baseAuth/login';

  /// Register endpoint.
  static const String register = '$baseAuth/register';

  /// Refresh token endpoint.
  static const String refreshToken = '$baseAuth/refresh';

  /// Logout endpoint.
  static const String logout = '$baseAuth/logout';

  /// Forgot password endpoint.
  static const String forgotPassword = '$baseAuth/forgot-password';

  /// Reset password endpoint.
  static const String resetPassword = '$baseAuth/reset-password';

  // ============================================================================
  // User Endpoints
  // ============================================================================

  /// Base path for user endpoints.
  static const String baseUsers = '/users';

  /// Current user profile endpoint.
  static const String profile = '$baseUsers/me';

  /// Update user profile endpoint.
  static const String updateProfile = '$baseUsers/me';

  // ============================================================================
  // Groups Endpoints
  // ============================================================================

  /// Base path for groups endpoints.
  static const String baseGroups = '/groups';

  /// Get user's groups endpoint.
  static const String myGroups = '$baseGroups/my';

  // ============================================================================
  // Goals Endpoints
  // ============================================================================

  /// Base path for goals endpoints.
  static const String baseGoals = '/goals';

  /// Get user's goals endpoint.
  static const String myGoals = '$baseGoals/my';

  // ============================================================================
  // Steps/Progress Endpoints
  // ============================================================================

  /// Base path for steps endpoints.
  static const String baseSteps = '/steps';

  /// Today's steps endpoint.
  static const String todaySteps = '$baseSteps/today';

  /// Steps history endpoint.
  static const String stepsHistory = '$baseSteps/history';

  // ============================================================================
  // Notifications Endpoints
  // ============================================================================

  /// Base path for notifications endpoints.
  static const String baseNotifications = '/notifications';

  /// Mark notification as read endpoint.
  static const String markNotificationRead = '$baseNotifications/read';

  // ============================================================================
  // Health Check
  // ============================================================================

  /// Health check endpoint.
  static const String health = '/health';
}
