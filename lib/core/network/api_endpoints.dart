/// API endpoints configuration for App Pasos.
///
/// This file contains all API endpoint paths used for network requests.
/// The base URL is loaded from environment variables with a fallback
/// for local development.
library;

/// API endpoint paths for the application.
///
/// All endpoint paths are relative to the [baseUrl]. Use these constants
/// throughout the app to ensure consistent endpoint references.
///
/// Example usage:
/// ```dart
/// final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.userProfile}';
/// final response = await dio.get(url);
/// ```
abstract final class ApiEndpoints {
  /// Base URL for the API.
  ///
  /// Loaded from the `API_BASE_URL` environment variable.
  /// Defaults to `http://localhost:3000/api` for local development.
  static String get baseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000/api',
      );

  // ============================================================
  // Authentication Endpoints
  // ============================================================

  /// POST: Authenticate user with email and password.
  ///
  /// Request body: `{ email: string, password: string }`
  /// Response: `{ token: string, refreshToken: string, user: User }`
  static const String login = '/auth/login';

  /// POST: Register a new user account.
  ///
  /// Request body: `{ email: string, password: string, name: string }`
  /// Response: `{ token: string, refreshToken: string, user: User }`
  static const String register = '/auth/register';

  /// POST: Refresh the authentication token.
  ///
  /// Request body: `{ refreshToken: string }`
  /// Response: `{ token: string, refreshToken: string }`
  static const String refreshToken = '/auth/refresh';

  /// POST: Logout and invalidate the current session.
  ///
  /// Requires authentication header.
  /// Response: `{ success: boolean }`
  static const String logout = '/auth/logout';

  /// POST: Request password reset email.
  ///
  /// Request body: `{ email: string }`
  /// Response: `{ success: boolean, message: string }`
  static const String forgotPassword = '/auth/forgot-password';

  /// POST: Reset password with token.
  ///
  /// Request body: `{ token: string, password: string }`
  /// Response: `{ success: boolean }`
  static const String resetPassword = '/auth/reset-password';

  // ============================================================
  // User Endpoints
  // ============================================================

  /// GET: Fetch the current user's profile.
  ///
  /// Requires authentication header.
  /// Response: `{ user: User }`
  static const String userProfile = '/users/profile';

  /// PUT: Update the current user's profile.
  ///
  /// Requires authentication header.
  /// Request body: `{ name?: string, email?: string, ... }`
  /// Response: `{ user: User }`
  static const String updateProfile = '/users/profile';

  /// PUT: Update the current user's password.
  ///
  /// Requires authentication header.
  /// Request body: `{ currentPassword: string, newPassword: string }`
  /// Response: `{ success: boolean }`
  static const String updatePassword = '/users/password';

  /// DELETE: Delete the current user's account.
  ///
  /// Requires authentication header.
  /// Response: `{ success: boolean }`
  static const String deleteAccount = '/users/account';

  // ============================================================
  // Steps/Habits Endpoints (Core Feature)
  // ============================================================

  /// GET/POST: List all steps or create a new step.
  ///
  /// GET: Returns list of user's steps.
  /// POST: Creates a new step.
  static const String steps = '/steps';

  /// GET/PUT/DELETE: Individual step operations.
  ///
  /// Use with step ID: `$step/:id`
  static const String step = '/steps';

  /// POST: Mark a step as completed.
  ///
  /// Path: `/steps/:id/complete`
  static const String completeStep = '/steps/{id}/complete';

  /// GET: Get step completion history.
  ///
  /// Path: `/steps/:id/history`
  static const String stepHistory = '/steps/{id}/history';

  // ============================================================
  // Statistics/Analytics Endpoints
  // ============================================================

  /// GET: Fetch user statistics and analytics.
  ///
  /// Query params: `{ startDate?: string, endDate?: string }`
  static const String statistics = '/statistics';

  /// GET: Fetch daily summary.
  ///
  /// Query params: `{ date: string }`
  static const String dailySummary = '/statistics/daily';

  /// GET: Fetch weekly summary.
  ///
  /// Query params: `{ weekStart: string }`
  static const String weeklySummary = '/statistics/weekly';

  // ============================================================
  // Steps Data Endpoints
  // ============================================================

  /// POST: Record new steps.
  ///
  /// Request body: `{ count: number, source: string }`
  /// Response: `{ step object }`
  static const String stepsRecord = '/steps';

  /// GET: Get today's total steps.
  ///
  /// Response: `{ today: number }`
  static const String stepsToday = '/steps/today';

  /// GET: Get weekly step trends.
  ///
  /// Response: `{ trend: [{ date: string, total: number }] }`
  static const String stepsWeekly = '/steps/weekly';

  /// GET: Get hourly peak data.
  ///
  /// Query params: `{ date?: string }` (YYYY-MM-DD format)
  /// Response: `{ peaks: [{ hour: number, total: number }] }`
  static const String stepsHourlyPeaks = '/steps/hourly-peaks';

  /// GET: Get step statistics.
  ///
  /// Response: `{ today: number, week: number, month: number, allTime: number }`
  static const String stepsStats = '/steps/stats';

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Builds a full URL from a path.
  ///
  /// Example: `ApiEndpoints.buildUrl('/users/profile')` returns
  /// `http://localhost:3000/api/users/profile`
  static String buildUrl(String path) => '$baseUrl$path';

  /// Builds a URL with path parameters replaced.
  ///
  /// Example: `ApiEndpoints.withParams('/steps/{id}/complete', {'id': '123'})`
  /// returns `/steps/123/complete`
  static String withParams(String path, Map<String, String> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
