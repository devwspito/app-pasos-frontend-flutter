import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/step_model.dart';

/// Local data source for caching step records.
///
/// Uses [SharedPreferences] for persistent local storage.
/// Provides caching and offline data access capabilities.
abstract class StepsLocalDataSource {
  /// Caches today's step record locally.
  ///
  /// [stepModel] - The step record to cache.
  Future<void> cacheTodaySteps(StepModel stepModel);

  /// Retrieves the cached today's step record.
  ///
  /// Returns [StepModel] if cached, or null if not found.
  Future<StepModel?> getCachedTodaySteps();

  /// Caches a list of step records locally.
  ///
  /// [steps] - The step records to cache.
  /// [key] - The cache key to use (e.g., 'weekly', 'monthly').
  Future<void> cacheSteps(List<StepModel> steps, String key);

  /// Retrieves cached step records by key.
  ///
  /// [key] - The cache key to retrieve.
  ///
  /// Returns a list of [StepModel] or empty list if not found.
  Future<List<StepModel>> getCachedSteps(String key);

  /// Saves a step record locally with pending sync flag.
  ///
  /// [stepModel] - The step record to save.
  ///
  /// Returns the saved [StepModel] with pendingSync set to true.
  Future<StepModel> saveLocalStepRecord(StepModel stepModel);

  /// Retrieves all step records pending sync to the server.
  ///
  /// Returns a list of [StepModel] with pendingSync = true.
  Future<List<StepModel>> getPendingSyncRecords();

  /// Marks records as synced (removes pending flag).
  ///
  /// [recordIds] - IDs of records to mark as synced.
  Future<void> markRecordsAsSynced(List<String> recordIds);

  /// Clears all cached step data.
  Future<void> clearCache();

  /// Stream of step records for real-time local updates.
  Stream<List<StepModel>> watchLocalSteps();
}

/// Implementation of [StepsLocalDataSource] using SharedPreferences.
class StepsLocalDataSourceImpl implements StepsLocalDataSource {
  final SharedPreferences _prefs;
  final StreamController<List<StepModel>> _stepsStreamController;

  /// Cache keys
  static const String _todayStepsKey = 'cached_today_steps';
  static const String _weeklyStepsKey = 'cached_weekly_steps';
  static const String _monthlyStepsKey = 'cached_monthly_steps';
  static const String _pendingSyncKey = 'pending_sync_steps';
  static const String _allCachedStepsKey = 'all_cached_steps';

  /// Creates a [StepsLocalDataSourceImpl] instance.
  ///
  /// Requires a [SharedPreferences] instance for storage.
  StepsLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs,
        _stepsStreamController = StreamController<List<StepModel>>.broadcast();

  @override
  Future<void> cacheTodaySteps(StepModel stepModel) async {
    final jsonString = jsonEncode(stepModel.toJson());
    await _prefs.setString(_todayStepsKey, jsonString);
    _notifyListeners();
  }

  @override
  Future<StepModel?> getCachedTodaySteps() async {
    final jsonString = _prefs.getString(_todayStepsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return StepModel.fromJson(json);
    } catch (e) {
      // Invalid cache, clear it
      await _prefs.remove(_todayStepsKey);
      return null;
    }
  }

  @override
  Future<void> cacheSteps(List<StepModel> steps, String key) async {
    final jsonList = steps.map((s) => s.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(key, jsonString);
    _notifyListeners();
  }

  @override
  Future<List<StepModel>> getCachedSteps(String key) async {
    final jsonString = _prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Invalid cache, clear it
      await _prefs.remove(key);
      return [];
    }
  }

  @override
  Future<StepModel> saveLocalStepRecord(StepModel stepModel) async {
    final pendingRecords = await getPendingSyncRecords();

    // Check if record already exists (by date)
    final existingIndex = pendingRecords.indexWhere(
      (r) =>
          r.date.year == stepModel.date.year &&
          r.date.month == stepModel.date.month &&
          r.date.day == stepModel.date.day,
    );

    final recordWithPending = stepModel.copyWith(pendingSync: true);

    if (existingIndex >= 0) {
      pendingRecords[existingIndex] = recordWithPending;
    } else {
      pendingRecords.add(recordWithPending);
    }

    await _savePendingSyncRecords(pendingRecords);
    _notifyListeners();

    return recordWithPending;
  }

  @override
  Future<List<StepModel>> getPendingSyncRecords() async {
    final jsonString = _prefs.getString(_pendingSyncKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
          .where((model) => model.pendingSync)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markRecordsAsSynced(List<String> recordIds) async {
    final pendingRecords = await getPendingSyncRecords();
    final updatedRecords = pendingRecords
        .where((r) => !recordIds.contains(r.id))
        .toList();

    await _savePendingSyncRecords(updatedRecords);
    _notifyListeners();
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_todayStepsKey);
    await _prefs.remove(_weeklyStepsKey);
    await _prefs.remove(_monthlyStepsKey);
    await _prefs.remove(_allCachedStepsKey);
    // Note: Don't clear pending sync records as they haven't been uploaded yet
    _notifyListeners();
  }

  @override
  Stream<List<StepModel>> watchLocalSteps() {
    return _stepsStreamController.stream;
  }

  /// Saves pending sync records to storage.
  Future<void> _savePendingSyncRecords(List<StepModel> records) async {
    final jsonList = records.map((r) => r.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_pendingSyncKey, jsonString);
  }

  /// Notifies listeners of step data changes.
  Future<void> _notifyListeners() async {
    final todaySteps = await getCachedTodaySteps();
    final pendingRecords = await getPendingSyncRecords();

    final allSteps = <StepModel>[];
    if (todaySteps != null) {
      allSteps.add(todaySteps);
    }
    allSteps.addAll(pendingRecords);

    if (!_stepsStreamController.isClosed) {
      _stepsStreamController.add(allSteps);
    }
  }

  /// Disposes resources.
  void dispose() {
    _stepsStreamController.close();
  }
}
