import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';

/// Router module for dependency injection.
///
/// Registers all routing-related dependencies:
/// - [GoRouter] application router instance
///
/// Usage in app:
/// ```dart
/// final router = sl<GoRouter>();
/// MaterialApp.router(routerConfig: router);
/// ```
abstract final class RouterModule {
  /// Registers router dependencies with the provided service locator.
  ///
  /// This method should be called during app initialization via
  /// [configureDependencies].
  static void register(GetIt sl) {
    // Register GoRouter as a lazy singleton
    sl.registerLazySingleton<GoRouter>(() => createAppRouter());
  }
}
