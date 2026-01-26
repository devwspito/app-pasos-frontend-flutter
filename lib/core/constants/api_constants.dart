abstract class ApiConstants {
  ApiConstants._();

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // API Paths
  static const String apiVersion = '/api/v1';
  static const String authPath = '/auth';
  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String refreshTokenPath = '/auth/refresh';
}
