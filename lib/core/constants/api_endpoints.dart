/// API endpoint definitions for the Pasos app.
///
/// This file contains all API endpoint paths organized by feature/domain.
/// Uses base path composition for maintainability.
library;

/// Base API paths for different versions and services.
abstract final class ApiBasePaths {
  /// API version 1 base path.
  static const String v1 = '/api/v1';

  /// WebSocket base path.
  static const String ws = '/ws';
}

/// Authentication related API endpoints.
///
/// Example usage:
/// ```dart
/// final loginUrl = '${baseUrl}${AuthEndpoints.login}';
/// dio.post(AuthEndpoints.login, data: credentials);
/// ```
abstract final class AuthEndpoints {
  static const String _base = '${ApiBasePaths.v1}/auth';

  /// POST - User login with email/password.
  static const String login = '$_base/login';

  /// POST - User registration.
  static const String register = '$_base/register';

  /// POST - Logout current session.
  static const String logout = '$_base/logout';

  /// POST - Refresh authentication token.
  static const String refreshToken = '$_base/refresh';

  /// POST - Request password reset email.
  static const String forgotPassword = '$_base/forgot-password';

  /// POST - Reset password with token.
  static const String resetPassword = '$_base/reset-password';

  /// POST - Verify email address.
  static const String verifyEmail = '$_base/verify-email';

  /// POST - Resend verification email.
  static const String resendVerification = '$_base/resend-verification';

  /// POST - Social authentication (Google, Apple, etc.).
  static const String socialAuth = '$_base/social';
}

/// User profile related API endpoints.
///
/// Example usage:
/// ```dart
/// dio.get(UserEndpoints.profile);
/// dio.put(UserEndpoints.profile, data: updatedProfile);
/// ```
abstract final class UserEndpoints {
  static const String _base = '${ApiBasePaths.v1}/users';

  /// GET - Current user profile.
  /// PUT - Update current user profile.
  static const String profile = '$_base/me';

  /// GET - User profile by ID.
  static String byId(String userId) => '$_base/$userId';

  /// PUT - Update user avatar.
  static const String avatar = '$_base/me/avatar';

  /// PUT - Update user preferences.
  static const String preferences = '$_base/me/preferences';

  /// DELETE - Delete user account.
  static const String deleteAccount = '$_base/me';

  /// GET - User statistics.
  static const String stats = '$_base/me/stats';
}

/// Steps tracking related API endpoints.
///
/// Example usage:
/// ```dart
/// dio.post(StepsEndpoints.sync, data: stepsData);
/// dio.get(StepsEndpoints.history(startDate, endDate));
/// ```
abstract final class StepsEndpoints {
  static const String _base = '${ApiBasePaths.v1}/steps';

  /// POST - Sync step count data.
  static const String sync = '$_base/sync';

  /// GET - Today's step count.
  static const String today = '$_base/today';

  /// GET - Step history for date range.
  static String history({
    required String startDate,
    required String endDate,
  }) =>
      '$_base/history?start=$startDate&end=$endDate';

  /// GET - Weekly summary.
  static const String weeklySummary = '$_base/summary/weekly';

  /// GET - Monthly summary.
  static const String monthlySummary = '$_base/summary/monthly';

  /// GET - Step goals.
  static const String goals = '$_base/goals';

  /// PUT - Update step goal.
  static const String updateGoal = '$_base/goals';
}

/// Group/Challenge related API endpoints.
///
/// Example usage:
/// ```dart
/// dio.get(GroupEndpoints.list);
/// dio.post(GroupEndpoints.create, data: groupData);
/// ```
abstract final class GroupEndpoints {
  static const String _base = '${ApiBasePaths.v1}/groups';

  /// GET - List user's groups.
  static const String list = _base;

  /// POST - Create new group.
  static const String create = _base;

  /// GET - Group details by ID.
  static String byId(String groupId) => '$_base/$groupId';

  /// PUT - Update group.
  static String update(String groupId) => '$_base/$groupId';

  /// DELETE - Delete group.
  static String delete(String groupId) => '$_base/$groupId';

  /// POST - Join group.
  static String join(String groupId) => '$_base/$groupId/join';

  /// POST - Leave group.
  static String leave(String groupId) => '$_base/$groupId/leave';

  /// GET - Group members.
  static String members(String groupId) => '$_base/$groupId/members';

  /// GET - Group leaderboard.
  static String leaderboard(String groupId) => '$_base/$groupId/leaderboard';
}

/// Achievement related API endpoints.
abstract final class AchievementEndpoints {
  static const String _base = '${ApiBasePaths.v1}/achievements';

  /// GET - List all achievements.
  static const String list = _base;

  /// GET - User's unlocked achievements.
  static const String unlocked = '$_base/unlocked';

  /// GET - Achievement details by ID.
  static String byId(String achievementId) => '$_base/$achievementId';
}

/// Notification related API endpoints.
abstract final class NotificationEndpoints {
  static const String _base = '${ApiBasePaths.v1}/notifications';

  /// GET - List notifications.
  static const String list = _base;

  /// PUT - Mark notification as read.
  static String markRead(String notificationId) => '$_base/$notificationId/read';

  /// PUT - Mark all notifications as read.
  static const String markAllRead = '$_base/read-all';

  /// DELETE - Delete notification.
  static String delete(String notificationId) => '$_base/$notificationId';

  /// POST - Register push notification token.
  static const String registerToken = '$_base/token';

  /// DELETE - Unregister push notification token.
  static const String unregisterToken = '$_base/token';
}

/// WebSocket event types for real-time communication.
abstract final class WebSocketEvents {
  /// Event for step count updates.
  static const String stepUpdate = 'step_update';

  /// Event for achievement unlocked.
  static const String achievementUnlocked = 'achievement_unlocked';

  /// Event for group updates.
  static const String groupUpdate = 'group_update';

  /// Event for leaderboard updates.
  static const String leaderboardUpdate = 'leaderboard_update';

  /// Event for new notification.
  static const String notification = 'notification';

  /// Event for connection established.
  static const String connected = 'connected';

  /// Event for connection error.
  static const String error = 'error';
}
