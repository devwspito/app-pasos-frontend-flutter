/// API endpoint paths for the App Pasos backend.
///
/// This class contains all API endpoint paths as static constants.
/// These paths should be appended to the base URL from [EnvConfig].
///
/// Example usage:
/// ```dart
/// final loginUrl = '${EnvConfig.apiBaseUrl}${ApiEndpoints.login}';
/// ```
abstract final class ApiEndpoints {
  // ============================================
  // Authentication Endpoints
  // ============================================

  /// Base path for authentication endpoints.
  static const String auth = '/auth';

  /// POST: User login endpoint.
  static const String login = '/auth/login';

  /// POST: User registration endpoint.
  static const String register = '/auth/register';

  /// POST: User logout endpoint.
  static const String logout = '/auth/logout';

  /// POST: Refresh authentication token.
  static const String refreshToken = '/auth/refresh';

  /// POST: Request password reset.
  static const String forgotPassword = '/auth/forgot-password';

  /// POST: Reset password with token.
  static const String resetPassword = '/auth/reset-password';

  // ============================================
  // User Endpoints
  // ============================================

  /// Base path for user endpoints.
  static const String users = '/users';

  /// GET/PUT: Current user profile.
  static const String profile = '/users/profile';

  /// PUT: Update user profile.
  static const String updateProfile = '/users/profile';

  /// PUT: Change user password.
  static const String changePassword = '/users/change-password';

  // ============================================
  // Group Endpoints
  // ============================================

  /// Base path for group endpoints.
  static const String groups = '/groups';

  /// GET: List user's groups.
  static const String myGroups = '/groups/my-groups';

  /// POST: Join a group.
  static const String joinGroup = '/groups/join';

  /// POST: Leave a group.
  static const String leaveGroup = '/groups/leave';

  // ============================================
  // Steps/Activity Endpoints
  // ============================================

  /// Base path for steps/activity endpoints.
  static const String steps = '/steps';

  /// GET: User's step history.
  static const String stepHistory = '/steps/history';

  /// POST: Log daily steps.
  static const String logSteps = '/steps/log';

  /// GET: Step statistics.
  static const String stepStats = '/steps/stats';

  // ============================================
  // Goals Endpoints
  // ============================================

  /// Base path for goals endpoints.
  static const String goals = '/goals';

  /// GET: User's active goals.
  static const String activeGoals = '/goals/active';

  /// GET: Goal progress.
  static const String goalProgress = '/goals/progress';

  // ============================================
  // Leaderboard Endpoints
  // ============================================

  /// Base path for leaderboard endpoints.
  static const String leaderboard = '/leaderboard';

  /// GET: Global leaderboard.
  static const String globalLeaderboard = '/leaderboard/global';

  /// GET: Group leaderboard (requires group ID).
  static const String groupLeaderboard = '/leaderboard/group';

  // ============================================
  // Health Check
  // ============================================

  /// GET: API health check endpoint.
  static const String health = '/health';
}
