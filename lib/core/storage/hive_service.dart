/// Hive database service for offline storage in App Pasos.
///
/// This file defines an abstract interface and implementation for Hive
/// database operations. Provides typed storage boxes for steps, goals,
/// and user data with offline-first capabilities.
library;

import 'package:hive_flutter/hive_flutter.dart';

/// Abstract interface for Hive storage operations.
///
/// This interface enables dependency injection and testing by allowing
/// mock implementations. All Hive storage operations should go through
/// this service.
///
/// Example usage:
/// ```dart
/// final hiveService = HiveServiceImpl();
/// await hiveService.initialize();
///
/// // Service is now ready to use
/// final isReady = hiveService.isInitialized;
/// print('Hive initialized: $isReady');
///
/// // Later, when app closes
/// await hiveService.closeBoxes();
/// ```
abstract interface class HiveService {
  /// Initializes the Hive database system.
  ///
  /// This method must be called before any storage operations.
  /// It sets up Hive with Flutter and opens all required boxes.
  ///
  /// Initialization includes:
  /// - Initializing Hive with Flutter directory
  /// - Opening all typed boxes (steps, goals, user)
  ///
  /// This method is idempotent - calling it multiple times has no
  /// additional effect after the first successful initialization.
  ///
  /// Throws an exception if initialization fails.
  Future<void> initialize();

  /// Opens all storage boxes.
  ///
  /// This is called automatically by [initialize], but can be called
  /// separately if boxes were closed and need to be reopened.
  ///
  /// Boxes opened:
  /// - steps_box: For step records keyed by date
  /// - goals_box: For goal data keyed by goal ID
  /// - user_box: For user profile and settings
  Future<void> openBoxes();

  /// Closes all open boxes.
  ///
  /// Call this when the app is terminating or when storage
  /// access is no longer needed. After calling this, [initialize]
  /// or [openBoxes] must be called again before using storage.
  ///
  /// This method is safe to call even if boxes are not open.
  Future<void> closeBoxes();

  /// Whether the Hive service has been initialized.
  ///
  /// Returns `true` if [initialize] has been called successfully.
  /// Returns `false` if not initialized or after [closeBoxes].
  bool get isInitialized;
}

/// Implementation of [HiveService] using hive_flutter.
///
/// This implementation provides offline storage capabilities through
/// Hive's fast key-value database. Data is stored locally and
/// persists across app restarts.
///
/// Example usage:
/// ```dart
/// final hiveService = HiveServiceImpl();
/// await hiveService.initialize();
///
/// // Now boxes can be accessed through their wrapper classes
/// final stepsBox = StepsBox();
/// await stepsBox.saveStepRecord('2024-01-15', {'count': 1500});
///
/// // When done
/// await hiveService.closeBoxes();
/// ```
class HiveServiceImpl implements HiveService {
  /// Creates a [HiveServiceImpl] instance.
  HiveServiceImpl();

  /// Tracks whether the service has been initialized.
  bool _isInitialized = false;

  /// Box name for the steps storage box.
  static const String stepsBoxName = 'steps_box';

  /// Box name for the goals storage box.
  static const String goalsBoxName = 'goals_box';

  /// Box name for the user storage box.
  static const String userBoxName = 'user_box';

  // ============================================================
  // Initialization
  // ============================================================

  @override
  Future<void> initialize() async {
    // Idempotent - skip if already initialized
    if (_isInitialized) {
      return;
    }

    try {
      // Initialize Hive with Flutter's app document directory
      await Hive.initFlutter();

      // Open all required boxes
      await openBoxes();

      _isInitialized = true;
    } catch (e) {
      // Re-throw with more context for debugging
      throw Exception('Failed to initialize Hive service: $e');
    }
  }

  // ============================================================
  // Box Management
  // ============================================================

  @override
  Future<void> openBoxes() async {
    try {
      // Open boxes if not already open
      if (!Hive.isBoxOpen(stepsBoxName)) {
        await Hive.openBox<Map<dynamic, dynamic>>(stepsBoxName);
      }
      if (!Hive.isBoxOpen(goalsBoxName)) {
        await Hive.openBox<Map<dynamic, dynamic>>(goalsBoxName);
      }
      if (!Hive.isBoxOpen(userBoxName)) {
        await Hive.openBox<Map<dynamic, dynamic>>(userBoxName);
      }
    } catch (e) {
      throw Exception('Failed to open Hive boxes: $e');
    }
  }

  @override
  Future<void> closeBoxes() async {
    try {
      // Close boxes if they are open
      if (Hive.isBoxOpen(stepsBoxName)) {
        await Hive.box<Map<dynamic, dynamic>>(stepsBoxName).close();
      }
      if (Hive.isBoxOpen(goalsBoxName)) {
        await Hive.box<Map<dynamic, dynamic>>(goalsBoxName).close();
      }
      if (Hive.isBoxOpen(userBoxName)) {
        await Hive.box<Map<dynamic, dynamic>>(userBoxName).close();
      }

      _isInitialized = false;
    } catch (e) {
      // Log but don't throw - closing should be safe to call anytime
      // In production, use proper logging
    }
  }

  // ============================================================
  // Status
  // ============================================================

  @override
  bool get isInitialized => _isInitialized;
}
