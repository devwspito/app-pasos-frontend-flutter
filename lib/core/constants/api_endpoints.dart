/// API endpoint constants for the application.
///
/// Contains all endpoint paths used for API communication.
class ApiEndpoints {
  /// Base URL for the API server
  static const String baseUrl = 'https://api.apppasos.com';

  /// API version prefix
  static const String apiVersion = '/api/v1';

  // Auth endpoints
  /// Login endpoint - POST
  static const String login = '/auth/login';

  /// Registration endpoint - POST
  static const String register = '/auth/register';

  /// Token refresh endpoint - POST
  static const String refreshToken = '/auth/refresh';

  /// Logout endpoint - POST
  static const String logout = '/auth/logout';

  /// Forgot password endpoint - POST
  static const String forgotPassword = '/auth/forgot-password';

  /// Reset password endpoint - POST
  static const String resetPassword = '/auth/reset-password';

  // User endpoints
  /// Get user profile endpoint - GET
  static const String userProfile = '/users/profile';

  /// Update user profile endpoint - PUT/PATCH
  static const String updateProfile = '/users/profile';

  // Health check
  /// Health check endpoint - GET
  static const String health = '/health';

  /// Constructs the full URL for a given endpoint.
  ///
  /// Example:
  /// ```dart
  /// final url = ApiEndpoints.fullUrl(ApiEndpoints.login);
  /// // Returns: 'https://api.apppasos.com/api/v1/auth/login'
  /// ```
  static String fullUrl(String endpoint) => '$baseUrl$apiVersion$endpoint';

  /// Prevent instantiation - this is a utility class
  ApiEndpoints._();
}
