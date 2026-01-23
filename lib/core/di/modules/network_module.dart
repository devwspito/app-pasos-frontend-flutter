import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../config/environment.dart';
import '../../network/api_client.dart';
import '../../network/auth_interceptor.dart';
import '../../network/connectivity_interceptor.dart';

/// Network module for dependency injection.
///
/// Registers all network-related dependencies:
/// - [Dio] HTTP client with configured interceptors
/// - [ApiClient] type-safe wrapper for HTTP operations
/// - [AuthInterceptor] for JWT authentication handling
/// - [ConnectivityInterceptor] for network connectivity checks
abstract final class NetworkModule {
  /// Base URL for API requests.
  /// TODO: Move to environment configuration when flutter_dotenv is set up.
  static const String _baseUrl = 'https://api.example.com';

  /// Registers network dependencies with the provided service locator.
  ///
  /// This method should be called during app initialization via
  /// [configureDependencies].
  ///
  /// Registration order matters:
  /// 1. Interceptors (depend on FlutterSecureStorage from StorageModule)
  /// 2. Dio (uses interceptors)
  /// 3. ApiClient (wraps Dio)
  static void register(GetIt sl) {
    // Register interceptors as lazy singletons
    sl.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(sl<FlutterSecureStorage>()),
    );
    sl.registerLazySingleton<ConnectivityInterceptor>(
      () => ConnectivityInterceptor(),
    );

    // Register Dio HTTP client as a lazy singleton
    sl.registerLazySingleton<Dio>(() => _createDio(sl));

    // Register ApiClient as a lazy singleton
    sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));
  }

  /// Creates and configures the Dio HTTP client with all interceptors.
  ///
  /// Interceptors are added in the following order:
  /// 1. ConnectivityInterceptor - Checks network before requests
  /// 2. AuthInterceptor - Adds JWT tokens to requests
  /// 3. LogInterceptor (dev only) - Logs request/response details
  static Dio _createDio(GetIt sl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add connectivity interceptor first to check network before making requests
    dio.interceptors.add(sl<ConnectivityInterceptor>());

    // Add auth interceptor for JWT token handling
    dio.interceptors.add(sl<AuthInterceptor>());

    // Add logging interceptor in development mode (last to log final request)
    if (Environment.isDevelopment) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }

    return dio;
  }
}
