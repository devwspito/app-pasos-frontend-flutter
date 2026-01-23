/// API endpoint paths for the Pasos backend.
///
/// Uses Dart 3 abstract final class pattern for type-safe endpoint groupings.
/// Note: Base URL should be configured via environment config, not hardcoded here.
abstract final class ApiEndpoints {
  // ============================================
  // Authentication Endpoints
  // ============================================

  /// POST - User login with credentials
  static const String login = '/auth/login';

  /// POST - User registration
  static const String register = '/auth/register';

  /// POST - Refresh access token using refresh token
  static const String refreshToken = '/auth/refresh';

  /// POST - User logout (invalidate tokens)
  static const String logout = '/auth/logout';

  /// POST - Request password reset email
  static const String forgotPassword = '/auth/forgot-password';

  /// POST - Reset password with token
  static const String resetPassword = '/auth/reset-password';

  // ============================================
  // User Endpoints
  // ============================================

  /// GET - Get current user profile
  /// PUT - Update current user profile
  static const String userProfile = '/users/profile';

  /// PUT - Update user profile (alias for clarity)
  static const String updateProfile = '/users/profile';

  /// GET - Get user by ID
  static String userById(String id) => '/users/$id';

  /// PUT - Update user avatar
  static const String updateAvatar = '/users/avatar';

  // ============================================
  // Steps/Pasos Endpoints
  // ============================================

  /// GET - List all steps
  /// POST - Create a new step
  static const String steps = '/steps';

  /// GET - Get step by ID
  /// PUT - Update step by ID
  /// DELETE - Delete step by ID
  static String stepById(String id) => '/steps/$id';

  /// POST - Complete a step
  static String completeStep(String id) => '/steps/$id/complete';

  /// POST - Uncomplete a step
  static String uncompleteStep(String id) => '/steps/$id/uncomplete';

  // ============================================
  // Goals Endpoints
  // ============================================

  /// GET - List all goals
  /// POST - Create a new goal
  static const String goals = '/goals';

  /// GET - Get goal by ID
  /// PUT - Update goal by ID
  /// DELETE - Delete goal by ID
  static String goalById(String id) => '/goals/$id';

  // ============================================
  // Progress/Statistics Endpoints
  // ============================================

  /// GET - Get user progress statistics
  static const String progress = '/progress';

  /// GET - Get daily progress
  static const String dailyProgress = '/progress/daily';

  /// GET - Get weekly progress
  static const String weeklyProgress = '/progress/weekly';

  /// GET - Get monthly progress
  static const String monthlyProgress = '/progress/monthly';
}
