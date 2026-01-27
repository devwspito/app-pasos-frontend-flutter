import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/network/dio_client.dart';
import 'core/utils/logger.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> initDependencies({EnvironmentConfig? environment}) async {
  // Initialize environment configuration
  AppConfig.init(environment ?? EnvironmentConfig.development);

  // Initialize logger
  AppLogger.init();

  // External dependencies
  _initExternalDependencies();

  // Core
  _initCore();

  // Repositories
  _initRepositories();

  // Services
  _initServices();

  AppLogger.i('Dependencies initialized successfully');
}

void _initExternalDependencies() {
  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );
}

void _initCore() {
  // Dio Client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(secureStorage: sl<FlutterSecureStorage>()),
  );
}

void _initRepositories() {
  // Repositories will be registered here in future epics
  // Example:
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(dioClient: sl()),
  // );
}

void _initServices() {
  // Services will be registered here in future epics
  // Example:
  // sl.registerLazySingleton<AuthService>(
  //   () => AuthServiceImpl(authRepository: sl()),
  // );
}

/// Reset all registered dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
