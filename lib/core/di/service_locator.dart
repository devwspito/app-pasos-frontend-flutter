import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Global GetIt instance for dependency injection.
///
/// Use this instance to register and resolve dependencies throughout the app.
///
/// Example:
/// ```dart
/// // Register a service
/// getIt.registerLazySingleton<UserService>(() => UserServiceImpl());
///
/// // Resolve a service
/// final userService = getIt<UserService>();
/// ```
final GetIt getIt = GetIt.instance;

/// Sets up all application dependencies.
///
/// This function should be called once at app startup, typically in main.dart
/// before runApp().
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await setupServiceLocator();
///   runApp(const MyApp());
/// }
/// ```
///
/// Dependencies are registered as lazy singletons for efficient resource usage.
/// They are only instantiated when first requested.
Future<void> setupServiceLocator() async {
  // ==========================================================================
  // Core Configuration
  // ==========================================================================

  // Register AppConfig singleton instance
  // AppConfig uses its own singleton pattern, so we register the instance
  getIt.registerLazySingleton<AppConfig>(
    () => AppConfig.instance,
  );

  // ==========================================================================
  // Logging
  // ==========================================================================

  // Register Logger with app-appropriate configuration
  getIt.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: AppConfig.instance.isProduction ? Level.warning : Level.debug,
    ),
  );

  // ==========================================================================
  // TODO: Network Layer (to be implemented in future stories)
  // ==========================================================================
  // getIt.registerLazySingleton<Dio>(() => _createDioClient());
  // getIt.registerLazySingleton<ApiClient>(() => ApiClientImpl(getIt<Dio>()));

  // ==========================================================================
  // TODO: Secure Storage (to be implemented in future stories)
  // ==========================================================================
  // getIt.registerLazySingleton<FlutterSecureStorage>(
  //   () => const FlutterSecureStorage(),
  // );
  // getIt.registerLazySingleton<SecureStorageService>(
  //   () => SecureStorageServiceImpl(getIt<FlutterSecureStorage>()),
  // );

  // ==========================================================================
  // TODO: Shared Preferences (to be implemented in future stories)
  // ==========================================================================
  // final prefs = await SharedPreferences.getInstance();
  // getIt.registerSingleton<SharedPreferences>(prefs);
  // getIt.registerLazySingleton<LocalStorageService>(
  //   () => LocalStorageServiceImpl(getIt<SharedPreferences>()),
  // );

  // ==========================================================================
  // TODO: Repositories (to be implemented in future stories)
  // ==========================================================================
  // getIt.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     apiClient: getIt<ApiClient>(),
  //     secureStorage: getIt<SecureStorageService>(),
  //   ),
  // );
  // getIt.registerLazySingleton<UserRepository>(
  //   () => UserRepositoryImpl(apiClient: getIt<ApiClient>()),
  // );
  // getIt.registerLazySingleton<StepRepository>(
  //   () => StepRepositoryImpl(apiClient: getIt<ApiClient>()),
  // );

  // ==========================================================================
  // TODO: BLoCs (to be implemented in future stories)
  // ==========================================================================
  // getIt.registerFactory<AuthBloc>(
  //   () => AuthBloc(authRepository: getIt<AuthRepository>()),
  // );
}

/// Resets the service locator for testing purposes.
///
/// Call this in test tearDown to ensure a clean state between tests.
///
/// Example:
/// ```dart
/// tearDown(() async {
///   await resetServiceLocator();
/// });
/// ```
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Checks if the service locator has been initialized.
///
/// Useful for preventing double initialization.
bool get isServiceLocatorReady => getIt.isRegistered<AppConfig>();
