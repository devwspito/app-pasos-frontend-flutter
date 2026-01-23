import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

/// Storage module for dependency injection.
///
/// Registers all storage-related dependencies:
/// - [FlutterSecureStorage] for secure key-value storage
///
/// Additional storage services (LocalStorageService, etc.) can be
/// registered here as the application grows.
abstract final class StorageModule {
  /// Registers storage dependencies with the provided service locator.
  ///
  /// This method should be called during app initialization via
  /// [configureDependencies].
  static void register(GetIt sl) {
    // Register FlutterSecureStorage as a lazy singleton
    // Uses Android EncryptedSharedPreferences and iOS Keychain
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
}
