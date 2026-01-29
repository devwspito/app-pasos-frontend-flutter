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

  /// WebSocket base URL derived from the HTTP base URL.
  ///
  /// Converts the HTTP base URL to WebSocket protocol:
  /// - `http://` becomes `ws://`
  /// - `https://` becomes `wss://`
  /// - Removes the `/api` suffix if present
  ///
  /// Example:
  /// - Input: `http://localhost:3000/api` → Output: `ws://localhost:3000`
  /// - Input: `https://api.example.com/api` → Output: `wss://api.example.com`
  static String get wsBaseUrl {
    var url = baseUrl;

    // Replace http:// with ws:// and https:// with wss://
    if (url.startsWith('https://')) {
      url = url.replaceFirst('https://', 'wss://');
    } else if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'ws://');
    } else {
      url = 'ws://$url';
    }

    // Remove /api suffix if present
    if (url.endsWith('/api')) {
      url = url.substring(0, url.length - 4);
    }

    return url;
  }

  /// WebSocket connection path.
  ///
  /// Use with [wsBaseUrl] to form the complete WebSocket URL:
  /// ```dart
  /// final wsUrl = '${ApiEndpoints.wsBaseUrl}${ApiEndpoints.wsConnect}';
  /// // Result: ws://localhost:3000/ws
  /// ```
  static const String wsConnect = '/ws';

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
  // Sharing/Friends Endpoints
  // ============================================================

  /// GET: Get all sharing relationships for the current user.
  ///
  /// Requires authentication header.
  /// Response: `{ relationships: SharingRelationship[] }`
  static const String sharingRelationships = '/sharing/relationships';

  /// POST: Send a friend request.
  ///
  /// Requires authentication header.
  /// Request body: `{ toUserId: string }`
  /// Response: `{ relationship: SharingRelationship }`
  static const String sharingRequest = '/sharing/request';

  /// POST: Accept a friend request.
  ///
  /// Requires authentication header.
  /// Request body: `{ relationshipId: string }`
  /// Response: `{ relationship: SharingRelationship }`
  static const String sharingAccept = '/sharing/accept';

  /// POST: Reject a friend request.
  ///
  /// Requires authentication header.
  /// Request body: `{ relationshipId: string }`
  /// Response: `{ success: boolean }`
  static const String sharingReject = '/sharing/reject';

  /// POST: Revoke a sharing relationship.
  ///
  /// Requires authentication header.
  /// Request body: `{ relationshipId: string }`
  /// Response: `{ success: boolean }`
  static const String sharingRevoke = '/sharing/revoke';

  /// GET: Get step statistics for a specific friend.
  ///
  /// Requires authentication header.
  /// Path: `/sharing/stats/{friendId}`
  /// Response: `{ stats: FriendStats }`
  static const String sharingStats = '/sharing/stats';

  /// GET: Search for users to add as friends.
  ///
  /// Requires authentication header.
  /// Query params: `{ query: string }`
  /// Response: `{ users: SharedUser[] }`
  static const String sharingSearch = '/sharing/search';

  // ============================================================
  // Goals Endpoints
  // ============================================================

  /// GET/POST: List all goals or create a new goal.
  ///
  /// GET: Returns list of user's group goals.
  /// POST: Creates a new group goal.
  /// Requires authentication header.
  /// Response: `{ goals: GroupGoal[] }` for GET
  /// Response: `{ goal: GroupGoal }` for POST
  static const String goals = '/goals';

  /// GET: Get detailed information about a specific goal.
  ///
  /// Requires authentication header.
  /// Path: `/goals/{id}`
  /// Response: `{ goal: GroupGoal }`
  static const String goalDetails = '/goals/{id}';

  /// GET: Get progress information for a specific goal.
  ///
  /// Requires authentication header.
  /// Path: `/goals/{id}/progress`
  /// Response: `{ progress: GoalProgress }`
  static const String goalProgress = '/goals/{id}/progress';

  /// POST: Invite a user to join a goal.
  ///
  /// Requires authentication header.
  /// Path: `/goals/{id}/invite`
  /// Request body: `{ userId: string }`
  /// Response: `{ success: boolean }`
  static const String goalInvite = '/goals/{id}/invite';

  /// POST: Join a goal that the user has been invited to.
  ///
  /// Requires authentication header.
  /// Path: `/goals/{id}/join`
  /// Response: `{ success: boolean }`
  static const String goalJoin = '/goals/{id}/join';

  /// POST: Leave a goal that the user is a member of.
  ///
  /// Requires authentication header.
  /// Path: `/goals/{id}/leave`
  /// Response: `{ success: boolean }`
  static const String goalLeave = '/goals/{id}/leave';

  /// GET: Get rankings for a specific goal.
  ///
  /// Requires authentication header.
  /// Path: `/goals/{id}/rankings`
  /// Response: `{ rankings: MemberContribution[] }`
  static const String goalRankings = '/goals/{id}/rankings';

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
