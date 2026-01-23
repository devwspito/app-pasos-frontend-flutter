import 'package:get_it/get_it.dart';

/// BLoC module for dependency injection.
///
/// Registers all BLoC-related dependencies. This module should be
/// registered last in the dependency chain as BLoCs typically depend
/// on repositories and services from other modules.
///
/// Example usage when adding a new BLoC:
/// ```dart
/// sl.registerFactory<AuthBloc>(() => AuthBloc(
///   authRepository: sl(),
///   userRepository: sl(),
/// ));
/// ```
abstract final class BlocModule {
  /// Registers BLoC dependencies with the provided service locator.
  ///
  /// Add BLoCs here as the application grows:
  /// ```dart
  /// sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  /// sl.registerFactory<HomeBloc>(() => HomeBloc(sl()));
  /// ```
  ///
  /// BLoCs should typically be registered as factories (new instance each time)
  /// rather than singletons, as they manage state that should be fresh per screen.
  static void register(GetIt sl) {
    // BLoCs will be registered here as features are implemented
    // Example: sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  }
}
