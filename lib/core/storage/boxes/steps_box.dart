/// Steps box for offline storage of step records in App Pasos.
///
/// This file provides a typed wrapper around a Hive box for storing
/// step records. Records are keyed by date string (YYYY-MM-DD format).
library;

import 'package:hive_flutter/hive_flutter.dart';

/// Wrapper class for the steps Hive box.
///
/// Provides typed methods for storing and retrieving step records.
/// Records are stored as Map<String, dynamic> and keyed by date.
///
/// Example usage:
/// ```dart
/// final stepsBox = StepsBox();
///
/// // Save a step record
/// await stepsBox.saveStepRecord('2024-01-15', {
///   'id': '123',
///   'userId': 'user-456',
///   'count': 1500,
///   'source': 'native',
///   'hour': 14,
///   'timestamp': DateTime.now().toIso8601String(),
/// });
///
/// // Retrieve a record
/// final record = stepsBox.getStepRecord('2024-01-15');
/// print('Steps on 2024-01-15: ${record?['count']}');
///
/// // Get all records
/// final allRecords = stepsBox.getAllRecords();
/// ```
class StepsBox {
  /// The name of this box in Hive storage.
  static const String boxName = 'steps_box';

  /// Key for storing the last sync timestamp.
  static const String _lastSyncKey = '_steps_last_sync_timestamp';

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
        'StepsBox is not open. Call HiveService.initialize() first.',
      );
    }
    return Hive.box<Map<dynamic, dynamic>>(boxName);
  }

  // ============================================================
  // CRUD Operations
  // ============================================================

  /// Saves a step record for the given date.
  ///
  /// [date] - The date string in YYYY-MM-DD format.
  /// [record] - The step record data as a Map.
  ///
  /// If a record already exists for this date, it will be overwritten.
  ///
  /// Example:
  /// ```dart
  /// await stepsBox.saveStepRecord('2024-01-15', {
  ///   'count': 1500,
  ///   'source': 'native',
  /// });
  /// ```
  Future<void> saveStepRecord(String date, Map<String, dynamic> record) async {
    // Convert to Map<dynamic, dynamic> for Hive compatibility
    final hiveMap = Map<dynamic, dynamic>.from(record);
    await _box.put(date, hiveMap);
  }

  /// Gets a step record for the given date.
  ///
  /// [date] - The date string in YYYY-MM-DD format.
  ///
  /// Returns the record as a Map, or `null` if no record exists
  /// for the given date.
  ///
  /// Example:
  /// ```dart
  /// final record = stepsBox.getStepRecord('2024-01-15');
  /// if (record != null) {
  ///   print('Steps: ${record['count']}');
  /// }
  /// ```
  Map<String, dynamic>? getStepRecord(String date) {
    final hiveMap = _box.get(date);
    if (hiveMap == null) {
      return null;
    }
    // Convert back to Map<String, dynamic>
    return _convertToStringDynamicMap(hiveMap);
  }

  /// Gets all stored step records.
  ///
  /// Returns a list of all records, excluding metadata keys.
  /// Returns an empty list if no records are stored.
  ///
  /// Example:
  /// ```dart
  /// final allRecords = stepsBox.getAllRecords();
  /// for (final record in allRecords) {
  ///   print('Date: ${record['date']}, Steps: ${record['count']}');
  /// }
  /// ```
  List<Map<String, dynamic>> getAllRecords() {
    final records = <Map<String, dynamic>>[];

    for (final key in _box.keys) {
      // Skip metadata keys
      if (key.toString().startsWith('_')) {
        continue;
      }

      final hiveMap = _box.get(key);
      if (hiveMap != null) {
        records.add(_convertToStringDynamicMap(hiveMap));
      }
    }

    return records;
  }

  /// Deletes a step record for the given date.
  ///
  /// [date] - The date string in YYYY-MM-DD format.
  ///
  /// This method is safe to call even if no record exists for the date.
  ///
  /// Example:
  /// ```dart
  /// await stepsBox.deleteRecord('2024-01-15');
  /// ```
  Future<void> deleteRecord(String date) async {
    await _box.delete(date);
  }

  /// Clears all step records from storage.
  ///
  /// This removes ALL records but keeps the box open.
  /// Use with caution as this cannot be undone.
  ///
  /// Example:
  /// ```dart
  /// await stepsBox.clearAll();
  /// ```
  Future<void> clearAll() async {
    await _box.clear();
  }

  // ============================================================
  // Sync Timestamp Management
  // ============================================================

  /// Gets the timestamp of the last synchronization.
  ///
  /// Returns the [DateTime] when steps were last synced with the server,
  /// or `null` if no sync has ever occurred.
  ///
  /// Example:
  /// ```dart
  /// final lastSync = stepsBox.getLastSyncTimestamp();
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
  /// await stepsBox.setLastSyncTimestamp(DateTime.now());
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
