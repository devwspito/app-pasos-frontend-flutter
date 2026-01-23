import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import 'core/config/app_config.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/storage/secure_storage.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Initialize environment config first
  await AppConfig.initialize();

  // Core
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Network
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  // Storage
  getIt.registerLazySingleton<SecureStorage>(
    () => SecureStorageImpl(),
  );

  // API Client (depends on SecureStorage)
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<SecureStorage>()),
  );
}

// Helper for easy access
T locate<T extends Object>() => getIt<T>();
