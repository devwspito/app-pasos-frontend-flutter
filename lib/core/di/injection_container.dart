import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/sharing/data/datasources/sharing_remote_datasource.dart';
import '../../features/sharing/data/repositories/sharing_repository_impl.dart';
import '../../features/sharing/domain/repositories/sharing_repository.dart';
import '../network/api_client.dart';
import '../network/api_interceptors.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

/// Global service locator instance.
///
/// Use this to access registered services throughout the app.
/// Alias 'sl' stands for "service locator" - a common convention.
final GetIt sl = GetIt.instance;

/// Configures all dependencies for the application.
///
/// Must be called before [runApp] in main.dart.
/// Registers dependencies in order: External → Core → Features.
Future<void> configureDependencies() async {
  // ============================================
  // External Dependencies
  // ============================================
  await _registerExternalDependencies();

  // ============================================
  // Core Dependencies
  // ============================================
  await _registerCoreDependencies();

  // ============================================
  // Feature Dependencies
  // ============================================
  _registerSharingDependencies();
}

/// Registers external package dependencies.
Future<void> _registerExternalDependencies() async {
  // Dio is registered through ApiClient, but we can also register
  // a bare Dio instance if needed for direct access
  sl.registerLazySingleton<Dio>(() => Dio());
}

/// Registers core service dependencies.
Future<void> _registerCoreDependencies() async {
  // Storage - needs async initialization
  await _registerStorageServices();

  // Network - depends on storage
  _registerNetworkServices();
}

/// Registers storage services with proper async initialization.
Future<void> _registerStorageServices() async {
  // SecureStorage - no async init needed, just create instance
  sl.registerLazySingleton<SecureStorage>(
    () => SecureStorageImpl(),
  );

  // LocalStorage - needs async initialization
  final localStorage = await LocalStorageImpl.init();
  sl.registerLazySingleton<LocalStorage>(() => localStorage);
}

/// Registers network-related services.
void _registerNetworkServices() {
  // Interceptors - depend on SecureStorage
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(secureStorage: sl<SecureStorage>()),
  );

  sl.registerLazySingleton<LoggingInterceptor>(
    () => LoggingInterceptor(),
  );

  sl.registerLazySingleton<ErrorInterceptor>(
    () => ErrorInterceptor(),
  );

  // ApiClient - depends on interceptors
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      authInterceptor: sl<AuthInterceptor>(),
      loggingInterceptor: sl<LoggingInterceptor>(),
      errorInterceptor: sl<ErrorInterceptor>(),
    ),
  );
}

/// Resets all registered dependencies.
///
/// Useful for testing or when user logs out.
Future<void> resetDependencies() async {
  await sl.reset();
}

/// Checks if dependencies have been configured.
bool get isDependenciesConfigured => sl.isRegistered<ApiClient>();

// ============================================
// Feature: Sharing/Friends
// ============================================

/// Registers sharing feature dependencies.
///
/// Registers in order: DataSources → Repositories
/// This follows the clean architecture pattern where:
/// - DataSources handle raw data operations (API calls)
/// - Repositories provide a clean interface to the domain layer
void _registerSharingDependencies() {
  // Data Sources - depend on ApiClient
  sl.registerLazySingleton<SharingRemoteDataSource>(
    () => SharingRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repositories - depend on DataSources
  sl.registerLazySingleton<SharingRepository>(
    () => SharingRepositoryImpl(remoteDataSource: sl<SharingRemoteDataSource>()),
  );
}
