/// Dependency injection container for App Pasos.
///
/// This file configures and initializes all application dependencies using
/// the get_it service locator pattern. All services should be registered
/// here and accessed via the [sl] global instance.
library;

import 'package:app_pasos_frontend/core/errors/error_handler.dart';
import 'package:app_pasos_frontend/core/network/api_client.dart';
import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:app_pasos_frontend/core/utils/logger.dart';
import 'package:app_pasos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_pasos_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_pasos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';

/// Global service locator instance.
///
/// Use this to access registered dependencies throughout the application:
/// ```dart
/// final apiClient = sl<ApiClient>();
/// final storage = sl<SecureStorageService>();
/// ```
final GetIt sl = GetIt.instance;

/// Initializes all application dependencies.
///
/// This function must be called before [runApp] in [main.dart].
/// It registers all services as lazy singletons, meaning they are
/// created only when first accessed and reused thereafter.
///
/// Registration order matters for dependencies that depend on other services.
/// The order is:
/// 1. Core utilities (Logger, ErrorHandler)
/// 2. Storage services
/// 3. Network services (which depend on storage)
///
/// Example usage in main.dart:
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initializeDependencies();
///   runApp(const App());
/// }
/// ```
Future<void> initializeDependencies() async {
  // ============================================================
  // Core Utilities
  // ============================================================

  // Logger - Singleton pattern built into AppLogger
  sl.registerLazySingleton<AppLogger>(AppLogger.new);

  // Error Handler - Depends on Logger internally
  sl.registerLazySingleton<ErrorHandler>(ErrorHandler.new);

  // ============================================================
  // Storage Services
  // ============================================================

  // Secure Storage - For sensitive data like tokens
  sl.registerLazySingleton<SecureStorageService>(
    SecureStorageServiceImpl.new,
  );

  // ============================================================
  // Network Services
  // ============================================================

  // API Client - Depends on SecureStorageService for auth token management
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(storage: sl<SecureStorageService>()),
  );

  // ============================================================
  // Auth Feature
  // ============================================================

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(client: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      datasource: sl<AuthRemoteDatasource>(),
      storage: sl<SecureStorageService>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(repository: sl<AuthRepository>()),
  );

  // Blocs (Factory - new instance per use)
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );
}

/// Resets all registered dependencies.
///
/// Use this for testing or when you need to reinitialize the app.
/// This will clear all registered singletons.
///
/// **Warning**: Only use this in tests or specific scenarios like
/// user logout where you want to clear all cached instances.
Future<void> resetDependencies() async {
  await sl.reset();
}
