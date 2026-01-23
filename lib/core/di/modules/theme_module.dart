import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../theme/app_theme.dart';

/// Theme module for dependency injection.
///
/// Registers theme-related dependencies:
/// - [ThemeData] for light theme (named 'lightTheme')
/// - [ThemeData] for dark theme (named 'darkTheme')
///
/// The themes are registered as lazy singletons to ensure consistent
/// theming throughout the application lifecycle.
///
/// Usage:
/// ```dart
/// // In injection_container.dart
/// ThemeModule.register(sl);
///
/// // To retrieve themes
/// final lightTheme = sl<ThemeData>(instanceName: 'lightTheme');
/// final darkTheme = sl<ThemeData>(instanceName: 'darkTheme');
/// ```
abstract final class ThemeModule {
  /// Registers theme dependencies with the provided service locator.
  ///
  /// This method should be called during app initialization via
  /// [configureDependencies].
  ///
  /// Registered dependencies:
  /// - Light [ThemeData] as lazy singleton with name 'lightTheme'
  /// - Dark [ThemeData] as lazy singleton with name 'darkTheme'
  static void register(GetIt sl) {
    // Register light theme as a lazy singleton
    sl.registerLazySingleton<ThemeData>(
      () => AppTheme.lightTheme(),
      instanceName: 'lightTheme',
    );

    // Register dark theme as a lazy singleton
    sl.registerLazySingleton<ThemeData>(
      () => AppTheme.darkTheme(),
      instanceName: 'darkTheme',
    );
  }
}
