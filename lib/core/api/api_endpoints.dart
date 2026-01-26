/// Type-safe API endpoint definitions for the application.
///
/// This class contains all API endpoint paths as static constants,
/// providing compile-time safety and centralized endpoint management.
library;

/// Abstract final class containing all API endpoint paths.
///
/// Usage:
/// ```dart
/// final url = ApiEndpoints.login;
/// final userUrl = ApiEndpoints.studyPlan('123');
/// ```
abstract final class ApiEndpoints {
  // ============================================================
  // Authentication Endpoints
  // ============================================================

  /// POST - User login endpoint.
  /// Request: { email, password }
  /// Response: { token, refreshToken, user }
  static const String login = '/auth/login';

  /// POST - User registration endpoint.
  /// Request: { email, password, name }
  /// Response: { token, refreshToken, user }
  static const String register = '/auth/register';

  /// POST - User logout endpoint.
  /// Request: { refreshToken }
  /// Response: { success }
  static const String logout = '/auth/logout';

  /// POST - Refresh access token endpoint.
  /// Request: { refreshToken }
  /// Response: { token, refreshToken }
  static const String refreshToken = '/auth/refresh';

  /// POST - Request password reset email.
  /// Request: { email }
  /// Response: { success, message }
  static const String forgotPassword = '/auth/forgot-password';

  /// POST - Reset password with token.
  /// Request: { token, newPassword }
  /// Response: { success }
  static const String resetPassword = '/auth/reset-password';

  /// POST - Verify email with token.
  /// Request: { token }
  /// Response: { success }
  static const String verifyEmail = '/auth/verify-email';

  /// POST - Resend verification email.
  /// Request: { email }
  /// Response: { success }
  static const String resendVerification = '/auth/resend-verification';

  // ============================================================
  // User Endpoints
  // ============================================================

  /// GET - Get current user profile.
  /// Response: { user }
  static const String userProfile = '/users/profile';

  /// PUT/PATCH - Update current user profile.
  /// Request: { name?, avatar?, preferences? }
  /// Response: { user }
  static const String updateProfile = '/users/profile';

  /// DELETE - Delete user account.
  /// Response: { success }
  static const String deleteAccount = '/users/account';

  /// PUT - Change user password.
  /// Request: { currentPassword, newPassword }
  /// Response: { success }
  static const String changePassword = '/users/password';

  /// GET - Get user preferences.
  /// Response: { preferences }
  static const String userPreferences = '/users/preferences';

  /// PUT - Update user preferences.
  /// Request: { preferences }
  /// Response: { preferences }
  static const String updatePreferences = '/users/preferences';

  // ============================================================
  // Study Plans Endpoints
  // ============================================================

  /// GET - Get all study plans for current user.
  /// Query: { page?, limit?, status? }
  /// Response: { studyPlans, total, page, limit }
  static const String studyPlans = '/study-plans';

  /// POST - Create a new study plan.
  /// Request: { title, description?, startDate?, endDate? }
  /// Response: { studyPlan }
  static const String createStudyPlan = '/study-plans';

  /// GET/PUT/DELETE - Operations on specific study plan.
  /// GET Response: { studyPlan }
  /// PUT Request: { title?, description?, status? }
  /// DELETE Response: { success }
  static String studyPlan(String id) => '/study-plans/$id';

  /// GET - Get study plan progress.
  /// Response: { progress, completedLessons, totalLessons }
  static String studyPlanProgress(String id) => '/study-plans/$id/progress';

  /// POST - Start a study plan.
  /// Response: { studyPlan }
  static String startStudyPlan(String id) => '/study-plans/$id/start';

  /// POST - Complete a study plan.
  /// Response: { studyPlan }
  static String completeStudyPlan(String id) => '/study-plans/$id/complete';

  // ============================================================
  // Lessons Endpoints
  // ============================================================

  /// GET - Get all lessons (optionally filtered by study plan).
  /// Query: { studyPlanId?, page?, limit?, status? }
  /// Response: { lessons, total, page, limit }
  static const String lessons = '/lessons';

  /// GET/PUT - Operations on specific lesson.
  /// GET Response: { lesson }
  /// PUT Request: { title?, content?, order? }
  static String lesson(String id) => '/lessons/$id';

  /// GET - Get lesson content.
  /// Response: { content, media }
  static String lessonContent(String id) => '/lessons/$id/content';

  /// POST - Mark lesson as complete.
  /// Request: { completedAt?, notes? }
  /// Response: { lesson, progress }
  static String completeLesson(String id) => '/lessons/$id/complete';

  /// POST - Mark lesson as started.
  /// Response: { lesson }
  static String startLesson(String id) => '/lessons/$id/start';

  /// GET - Get lessons for a specific study plan.
  /// Response: { lessons }
  static String studyPlanLessons(String studyPlanId) =>
      '/study-plans/$studyPlanId/lessons';

  // ============================================================
  // Progress Endpoints
  // ============================================================

  /// GET - Get overall user progress.
  /// Response: { overallProgress, streaks, achievements }
  static const String progress = '/progress';

  /// GET - Get progress statistics.
  /// Query: { period?, startDate?, endDate? }
  /// Response: { statistics }
  static const String progressStats = '/progress/stats';

  /// GET - Get daily progress.
  /// Query: { date? }
  /// Response: { dailyProgress }
  static const String dailyProgress = '/progress/daily';

  // ============================================================
  // Notifications Endpoints
  // ============================================================

  /// GET - Get user notifications.
  /// Query: { page?, limit?, unreadOnly? }
  /// Response: { notifications, total, unread }
  static const String notifications = '/notifications';

  /// PUT - Mark notification as read.
  /// Response: { notification }
  static String markNotificationRead(String id) => '/notifications/$id/read';

  /// PUT - Mark all notifications as read.
  /// Response: { success }
  static const String markAllNotificationsRead = '/notifications/read-all';

  /// DELETE - Delete a notification.
  /// Response: { success }
  static String deleteNotification(String id) => '/notifications/$id';

  // ============================================================
  // Settings Endpoints
  // ============================================================

  /// GET - Get app settings.
  /// Response: { settings }
  static const String settings = '/settings';

  /// PUT - Update app settings.
  /// Request: { settings }
  /// Response: { settings }
  static const String updateSettings = '/settings';

  // ============================================================
  // Health Check
  // ============================================================

  /// GET - API health check.
  /// Response: { status, version }
  static const String health = '/health';

  /// GET - API version info.
  /// Response: { version, minSupportedVersion }
  static const String version = '/version';
}
