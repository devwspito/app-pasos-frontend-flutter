import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../config/environment.dart';

/// Network module for dependency injection.
///
/// Registers all network-related dependencies:
/// - [Dio] HTTP client with configured interceptors
///
/// Additional network services (ApiClient, custom interceptors) can be
/// registered here as the application grows.
abstract final class NetworkModule {
  /// Base URL for API requests.
  /// TODO: Move to environment configuration.
  static const String _baseUrl = 'https://api.example.com';

  /// Registers network dependencies with the provided service locator.
  ///
  /// This method should be called during app initialization via
  /// [configureDependencies].
  static void register(GetIt sl) {
    // Register Dio HTTP client as a lazy singleton
    sl.registerLazySingleton<Dio>(() => _createDio());
  }

  /// Creates and configures the Dio HTTP client.
  static Dio _createDio() {
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

    // Add logging interceptor in development mode
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
