/// API endpoint definitions for all backend services.
///
/// Centralizes all API routes to ensure consistency and easy maintenance.
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST - Register a new user
  static const String register = '/auth/register';

  /// POST - Login with credentials
  static const String login = '/auth/login';

  /// POST - Refresh access token
  static const String refresh = '/auth/refresh';

  /// GET - Get current authenticated user
  static const String me = '/auth/me';

  // ═══════════════════════════════════════════════════════════════════════════
  // STEPS ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// GET/POST - Base steps endpoint
  static const String steps = '/steps';

  /// GET - Get today's step count
  static const String stepsToday = '/steps/today';

  /// GET - Get weekly step data
  static const String stepsWeekly = '/steps/weekly';

  /// GET - Get hourly peak activity
  static const String stepsHourlyPeaks = '/steps/hourly-peaks';

  /// GET - Get step statistics
  static const String stepsStats = '/steps/stats';

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARING ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST - Request to share steps with another user
  static const String sharingRequest = '/sharing/request';

  /// GET - List all sharing relationships
  static const String sharingList = '/sharing';

  /// PUT - Accept a sharing request by ID
  static String sharingAccept(String id) => '/sharing/$id/accept';

  /// PUT - Reject a sharing request by ID
  static String sharingReject(String id) => '/sharing/$id/reject';

  /// DELETE - Remove a sharing relationship by ID
  static String sharingDelete(String id) => '/sharing/$id';

  /// GET - Get shared user's step statistics
  static String sharingUserStats(String userId) => '/sharing/$userId/stats';

  // ═══════════════════════════════════════════════════════════════════════════
  // GOALS ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// GET/POST - Base goals endpoint
  static const String goals = '/goals';

  /// GET/PUT/DELETE - Goal by ID
  static String goalById(String id) => '/goals/$id';

  /// POST - Invite users to a goal
  static String goalInvite(String id) => '/goals/$id/invite';

  /// POST - Join a goal
  static String goalJoin(String id) => '/goals/$id/join';

  /// POST - Leave a goal
  static String goalLeave(String id) => '/goals/$id/leave';

  /// GET - Get goal progress
  static String goalProgress(String id) => '/goals/$id/progress';

  // ═══════════════════════════════════════════════════════════════════════════
  // USERS ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// GET - Search for users
  static const String usersSearch = '/users/search';

  /// GET - Check if username is available
  static String checkUsername(String username) =>
      '/users/check/username/$username';

  /// GET - Check if email is available
  static String checkEmail(String email) => '/users/check/email/$email';

  /// GET - Get user by username
  static String userByUsername(String username) => '/users/username/$username';

  /// GET - Get user by ID
  static String userById(String id) => '/users/$id';
}
