/// API endpoint paths and configuration.
///
/// Uses Dart 3 `abstract final class` pattern to prevent instantiation.
/// Base URL should be configured via environment variables.
abstract final class ApiEndpoints {
  /// Base URL for the API.
  /// This should be overridden by environment configuration.
  /// Use `String.fromEnvironment` or a config service in production.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001/api',
  );

  /// API version prefix.
  static const String apiVersion = '/v1';

  // ============================================
  // Authentication Endpoints
  // ============================================

  /// Login endpoint.
  static const String login = '/auth/login';

  /// Register endpoint.
  static const String register = '/auth/register';

  /// Logout endpoint.
  static const String logout = '/auth/logout';

  /// Refresh token endpoint.
  static const String refreshToken = '/auth/refresh';

  /// Password reset request endpoint.
  static const String forgotPassword = '/auth/forgot-password';

  /// Password reset confirmation endpoint.
  static const String resetPassword = '/auth/reset-password';

  /// Email verification endpoint.
  static const String verifyEmail = '/auth/verify-email';

  // ============================================
  // User Endpoints
  // ============================================

  /// Get current user profile.
  static const String userProfile = '/users/me';

  /// Update user profile.
  static const String updateProfile = '/users/me';

  /// Change password endpoint.
  static const String changePassword = '/users/me/password';

  /// Delete account endpoint.
  static const String deleteAccount = '/users/me';

  /// Get user by ID.
  static String getUserById(String userId) => '/users/$userId';

  // ============================================
  // Goals Endpoints
  // ============================================

  /// Get all goals.
  static const String goals = '/goals';

  /// Get goal by ID.
  static String getGoalById(String goalId) => '/goals/$goalId';

  /// Create new goal.
  static const String createGoal = '/goals';

  /// Update goal by ID.
  static String updateGoal(String goalId) => '/goals/$goalId';

  /// Delete goal by ID.
  static String deleteGoal(String goalId) => '/goals/$goalId';

  /// Get goal progress.
  static String goalProgress(String goalId) => '/goals/$goalId/progress';

  // ============================================
  // Steps Endpoints
  // ============================================

  /// Get all steps for a goal.
  static String goalSteps(String goalId) => '/goals/$goalId/steps';

  /// Get step by ID.
  static String getStepById(String goalId, String stepId) =>
      '/goals/$goalId/steps/$stepId';

  /// Create new step for a goal.
  static String createStep(String goalId) => '/goals/$goalId/steps';

  /// Update step by ID.
  static String updateStep(String goalId, String stepId) =>
      '/goals/$goalId/steps/$stepId';

  /// Delete step by ID.
  static String deleteStep(String goalId, String stepId) =>
      '/goals/$goalId/steps/$stepId';

  /// Mark step as complete.
  static String completeStep(String goalId, String stepId) =>
      '/goals/$goalId/steps/$stepId/complete';

  // ============================================
  // Step Tracking Endpoints (Physical Activity)
  // ============================================

  /// Get today's step statistics.
  static const String todayStats = '/steps/today';

  /// Get weekly step trend.
  static const String weeklyTrend = '/steps/weekly';

  /// Get hourly breakdown for a specific date.
  static const String hourlyBreakdown = '/steps/hourly';

  /// Record new steps (POST).
  static const String recordSteps = '/steps';

  // ============================================
  // Notifications Endpoints
  // ============================================

  /// Get all notifications.
  static const String notifications = '/notifications';

  /// Mark notification as read.
  static String markNotificationRead(String notificationId) =>
      '/notifications/$notificationId/read';

  /// Mark all notifications as read.
  static const String markAllNotificationsRead = '/notifications/read-all';

  // ============================================
  // Utility Methods
  // ============================================

  /// Builds a full URL from an endpoint path.
  static String buildUrl(String endpoint) => '$baseUrl$apiVersion$endpoint';

  /// Builds a paginated URL with query parameters.
  static String buildPaginatedUrl(
    String endpoint, {
    int page = 1,
    int pageSize = 20,
    Map<String, String>? additionalParams,
  }) {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (additionalParams != null) ...additionalParams,
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '${buildUrl(endpoint)}?$queryString';
  }
}
