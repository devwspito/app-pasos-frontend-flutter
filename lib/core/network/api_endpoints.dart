/// API endpoint constants for the application.
///
/// Centralizes all API paths to ensure consistency and easy maintenance.
/// Prevents typos and enables easy refactoring of endpoint paths.
abstract final class ApiEndpoints {
  /// Base URL for the API.
  /// TODO: Move to environment configuration for different environments.
  static const String baseUrl = 'https://api.pasos.app';

  // ===========================================================================
  // Authentication Endpoints
  // ===========================================================================

  /// Login endpoint - POST
  static const String login = '/auth/login';

  /// Register endpoint - POST
  static const String register = '/auth/register';

  /// Logout endpoint - POST
  static const String logout = '/auth/logout';

  /// Refresh token endpoint - POST
  static const String refreshToken = '/auth/refresh';

  /// Password reset request endpoint - POST
  static const String forgotPassword = '/auth/forgot-password';

  /// Password reset endpoint - POST
  static const String resetPassword = '/auth/reset-password';

  // ===========================================================================
  // User Endpoints
  // ===========================================================================

  /// Get current user profile - GET
  static const String userProfile = '/users/me';

  /// Update user profile - PUT
  static const String updateProfile = '/users/me';

  /// Get user by ID - GET
  static String user(String id) => '/users/$id';

  // ===========================================================================
  // Goals Endpoints
  // ===========================================================================

  /// Get all goals - GET
  static const String goals = '/goals';

  /// Get goal by ID - GET
  static String goal(String id) => '/goals/$id';

  /// Create goal - POST
  static const String createGoal = '/goals';

  // ===========================================================================
  // Steps/Progress Endpoints
  // ===========================================================================

  /// Get steps for a goal - GET
  static String goalSteps(String goalId) => '/goals/$goalId/steps';

  /// Log step progress - POST
  static String logStep(String goalId) => '/goals/$goalId/steps';

  // ===========================================================================
  // Group Endpoints
  // ===========================================================================

  /// Get all groups - GET
  static const String groups = '/groups';

  /// Get group by ID - GET
  static String group(String id) => '/groups/$id';

  /// Join a group - POST
  static String joinGroup(String id) => '/groups/$id/join';

  /// Leave a group - POST
  static String leaveGroup(String id) => '/groups/$id/leave';

  // ===========================================================================
  // Notification Endpoints
  // ===========================================================================

  /// Get all notifications - GET
  static const String notifications = '/notifications';

  /// Mark notification as read - PUT
  static String markNotificationRead(String id) => '/notifications/$id/read';

  /// Mark all notifications as read - PUT
  static const String markAllNotificationsRead = '/notifications/read-all';
}
