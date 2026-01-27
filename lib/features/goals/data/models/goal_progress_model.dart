/// Goal progress model for the data layer.
///
/// This file contains the data model for GoalProgress, extending the domain
/// entity and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/goal_progress.dart';

/// Data model extending [GoalProgress] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   '_id': '123',
///   'goalId': 'goal456',
///   'currentSteps': 25000,
///   'targetSteps': 50000,
///   'progressPercentage': 50.0,
///   'lastUpdated': '2024-01-15T00:00:00.000Z',
/// };
/// final model = GoalProgressModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class GoalProgressModel extends GoalProgress {
  /// Creates a [GoalProgressModel] instance.
  const GoalProgressModel({
    required super.id,
    required super.goalId,
    required super.currentSteps,
    required super.targetSteps,
    required super.progressPercentage,
    required super.lastUpdated,
  });

  /// Creates a [GoalProgressModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "_id": "string",
  ///   "goalId": "string",
  ///   "currentSteps": 25000,
  ///   "targetSteps": 50000,
  ///   "progressPercentage": 50.0,
  ///   "lastUpdated": "2024-01-15T00:00:00.000Z"
  /// }
  /// ```
  factory GoalProgressModel.fromJson(Map<String, dynamic> json) {
    return GoalProgressModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      goalId: json['goalId'] as String? ?? '',
      currentSteps: _parseInt(json['currentSteps']) ?? 0,
      targetSteps: _parseInt(json['targetSteps']) ?? 0,
      progressPercentage: _parseDouble(json['progressPercentage']) ?? 0.0,
      lastUpdated: _parseDateTime(json['lastUpdated']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Creates a [GoalProgressModel] from a domain [GoalProgress] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory GoalProgressModel.fromEntity(GoalProgress progress) {
    return GoalProgressModel(
      id: progress.id,
      goalId: progress.goalId,
      currentSteps: progress.currentSteps,
      targetSteps: progress.targetSteps,
      progressPercentage: progress.progressPercentage,
      lastUpdated: progress.lastUpdated,
    );
  }

  /// Creates an empty [GoalProgressModel] for initial states.
  factory GoalProgressModel.empty() => GoalProgressModel(
        id: '',
        goalId: '',
        currentSteps: 0,
        targetSteps: 0,
        progressPercentage: 0,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'currentSteps': currentSteps,
      'targetSteps': targetSteps,
      'progressPercentage': progressPercentage,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  GoalProgressModel copyWith({
    String? id,
    String? goalId,
    int? currentSteps,
    int? targetSteps,
    double? progressPercentage,
    DateTime? lastUpdated,
  }) {
    return GoalProgressModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      currentSteps: currentSteps ?? this.currentSteps,
      targetSteps: targetSteps ?? this.targetSteps,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Creates a list of [GoalProgressModel] from a JSON list.
  ///
  /// Useful for parsing API responses that return a list of progress records.
  static List<GoalProgressModel> fromJsonList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) {
      return [];
    }
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(GoalProgressModel.fromJson)
        .toList();
  }

  /// Safely parses an integer from various types.
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safely parses a double from various types.
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safely parses a DateTime from various types.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
