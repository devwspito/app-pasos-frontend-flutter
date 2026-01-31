/// Goals box for offline storage of group goals in App Pasos.
///
/// This file provides a typed wrapper around a Hive box for storing
/// group goal records. Records are keyed by goal ID string.
library;

import 'package:hive_flutter/hive_flutter.dart';

/// Wrapper class for the goals Hive box.
///
/// Provides typed methods for storing and retrieving group goal data.
/// Records are stored as Map<String, dynamic> and keyed by goal ID.
///
/// Example usage:
/// ```dart
/// final goalsBox = GoalsBox();
///
/// // Save a goal
/// await goalsBox.saveGoal('goal-123', {
///   'id': 'goal-123',
///   'name': 'Summer Challenge',
///   'description': 'Walk 100k steps together!',
///   'targetSteps': 100000,
///   'startDate': '2024-06-01T00:00:00.000Z',
///   'endDate': '2024-06-30T00:00:00.000Z',
///   'creatorId': 'user123',
///   'status': 'active',
/// });
///
/// // Retrieve a goal
/// final goal = goalsBox.getGoal('goal-123');
/// print('Goal name: ${goal?['name']}');
///
/// // Get all goals
/// final allGoals = goalsBox.getAllGoals();
/// ```
class GoalsBox {
  /// The name of this box in Hive storage.
  static const String boxName = 'goals_box';

  /// Key for storing the last sync timestamp.
  static const String _lastSyncKey = '_goals_last_sync_timestamp';

  // ============================================================
  // Box Access
  // ============================================================

  /// Gets the underlying Hive box.
  ///
  /// Throws `HiveError` if the box is not open.
  /// Ensure `HiveService.initialize()` has been called first.
  Box<Map<dynamic, dynamic>> get _box {
    if (!Hive.isBoxOpen(boxName)) {
      throw HiveError(
        'GoalsBox is not open. Call HiveService.initialize() first.',
      );
    }
    return Hive.box<Map<dynamic, dynamic>>(boxName);
  }

  // ============================================================
  // CRUD Operations
  // ============================================================

  /// Saves a goal with the given ID.
  ///
  /// [goalId] - The unique identifier for the goal.
  /// [goal] - The goal data as a Map.
  ///
  /// If a goal already exists with this ID, it will be overwritten.
  ///
  /// Example:
  /// ```dart
  /// await goalsBox.saveGoal('goal-123', {
  ///   'name': 'Summer Challenge',
  ///   'targetSteps': 100000,
  /// });
  /// ```
  Future<void> saveGoal(String goalId, Map<String, dynamic> goal) async {
    // Convert to Map<dynamic, dynamic> for Hive compatibility
    final hiveMap = Map<dynamic, dynamic>.from(goal);
    await _box.put(goalId, hiveMap);
  }

  /// Gets a goal by its ID.
  ///
  /// [goalId] - The unique identifier for the goal.
  ///
  /// Returns the goal as a Map, or `null` if no goal exists
  /// with the given ID.
  ///
  /// Example:
  /// ```dart
  /// final goal = goalsBox.getGoal('goal-123');
  /// if (goal != null) {
  ///   print('Goal: ${goal['name']}');
  /// }
  /// ```
  Map<String, dynamic>? getGoal(String goalId) {
    final hiveMap = _box.get(goalId);
    if (hiveMap == null) {
      return null;
    }
    // Convert back to Map<String, dynamic>
    return _convertToStringDynamicMap(hiveMap);
  }

  /// Gets all stored goals.
  ///
  /// Returns a list of all goals, excluding metadata keys.
  /// Returns an empty list if no goals are stored.
  ///
  /// Example:
  /// ```dart
  /// final allGoals = goalsBox.getAllGoals();
  /// for (final goal in allGoals) {
  ///   print('Goal: ${goal['name']}, Target: ${goal['targetSteps']}');
  /// }
  /// ```
  List<Map<String, dynamic>> getAllGoals() {
    final goals = <Map<String, dynamic>>[];

    for (final key in _box.keys) {
      // Skip metadata keys
      if (key.toString().startsWith('_')) {
        continue;
      }

      final hiveMap = _box.get(key);
      if (hiveMap != null) {
        goals.add(_convertToStringDynamicMap(hiveMap));
      }
    }

    return goals;
  }

  /// Deletes a goal by its ID.
  ///
  /// [goalId] - The unique identifier for the goal to delete.
  ///
  /// This method is safe to call even if no goal exists with the ID.
  ///
  /// Example:
  /// ```dart
  /// await goalsBox.deleteGoal('goal-123');
  /// ```
  Future<void> deleteGoal(String goalId) async {
    await _box.delete(goalId);
  }

  /// Clears all goals from storage.
  ///
  /// This removes ALL goals but keeps the box open.
  /// Use with caution as this cannot be undone.
  ///
  /// Example:
  /// ```dart
  /// await goalsBox.clearAll();
  /// ```
  Future<void> clearAll() async {
    await _box.clear();
  }

  // ============================================================
  // Sync Timestamp Management
  // ============================================================

  /// Gets the timestamp of the last synchronization.
  ///
  /// Returns the [DateTime] when goals were last synced with the server,
  /// or `null` if no sync has ever occurred.
  ///
  /// Example:
  /// ```dart
  /// final lastSync = goalsBox.getLastSyncTimestamp();
  /// if (lastSync != null) {
  ///   print('Last synced: $lastSync');
  /// }
  /// ```
  DateTime? getLastSyncTimestamp() {
    final hiveMap = _box.get(_lastSyncKey);
    if (hiveMap == null) {
      return null;
    }

    final timestamp = hiveMap['timestamp'];
    if (timestamp == null) {
      return null;
    }

    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }

    return null;
  }

  /// Sets the last synchronization timestamp.
  ///
  /// [timestamp] - The [DateTime] of the sync operation.
  ///
  /// Call this after a successful sync with the server.
  ///
  /// Example:
  /// ```dart
  /// await goalsBox.setLastSyncTimestamp(DateTime.now());
  /// ```
  Future<void> setLastSyncTimestamp(DateTime timestamp) async {
    final hiveMap = <dynamic, dynamic>{
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
    await _box.put(_lastSyncKey, hiveMap);
  }

  // ============================================================
  // Helpers
  // ============================================================

  /// Converts a Hive Map to Map<String, dynamic>.
  Map<String, dynamic> _convertToStringDynamicMap(
    Map<dynamic, dynamic> hiveMap,
  ) {
    return hiveMap.map((key, value) {
      if (value is Map<dynamic, dynamic>) {
        return MapEntry(
          key.toString(),
          _convertToStringDynamicMap(value),
        );
      }
      return MapEntry(key.toString(), value);
    });
  }
}
