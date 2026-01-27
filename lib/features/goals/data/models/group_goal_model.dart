/// Group goal model for the data layer.
///
/// This file contains the data model for GroupGoal, extending the domain
/// entity and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';

/// Data model extending [GroupGoal] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   '_id': '123',
///   'name': 'Summer Challenge',
///   'description': 'Walk 100k steps together!',
///   'targetSteps': 100000,
///   'startDate': '2024-06-01T00:00:00.000Z',
///   'endDate': '2024-06-30T00:00:00.000Z',
///   'creatorId': 'user123',
///   'status': 'active',
///   'createdAt': '2024-01-01T00:00:00.000Z',
/// };
/// final model = GroupGoalModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class GroupGoalModel extends GroupGoal {
  /// Creates a [GroupGoalModel] instance.
  const GroupGoalModel({
    required super.id,
    required super.name,
    required super.targetSteps,
    required super.startDate,
    required super.endDate,
    required super.creatorId,
    required super.status,
    required super.createdAt,
    super.description,
  });

  /// Creates a [GroupGoalModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "_id": "string",
  ///   "name": "string",
  ///   "description": "string",
  ///   "targetSteps": 50000,
  ///   "startDate": "2024-01-01T00:00:00.000Z",
  ///   "endDate": "2024-01-31T00:00:00.000Z",
  ///   "creatorId": "string",
  ///   "status": "active",
  ///   "createdAt": "2024-01-01T00:00:00.000Z"
  /// }
  /// ```
  factory GroupGoalModel.fromJson(Map<String, dynamic> json) {
    return GroupGoalModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      targetSteps: _parseInt(json['targetSteps']) ?? 0,
      startDate: _parseDateTime(json['startDate']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate: _parseDateTime(json['endDate']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      creatorId: json['creatorId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Creates a [GroupGoalModel] from a domain [GroupGoal] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory GroupGoalModel.fromEntity(GroupGoal goal) {
    return GroupGoalModel(
      id: goal.id,
      name: goal.name,
      description: goal.description,
      targetSteps: goal.targetSteps,
      startDate: goal.startDate,
      endDate: goal.endDate,
      creatorId: goal.creatorId,
      status: goal.status,
      createdAt: goal.createdAt,
    );
  }

  /// Creates an empty [GroupGoalModel] for initial states.
  factory GroupGoalModel.empty() => GroupGoalModel(
        id: '',
        name: '',
        targetSteps: 0,
        startDate: DateTime.fromMillisecondsSinceEpoch(0),
        endDate: DateTime.fromMillisecondsSinceEpoch(0),
        creatorId: '',
        status: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'targetSteps': targetSteps,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'creatorId': creatorId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  GroupGoalModel copyWith({
    String? id,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
    String? creatorId,
    String? status,
    DateTime? createdAt,
  }) {
    return GroupGoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetSteps: targetSteps ?? this.targetSteps,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a list of [GroupGoalModel] from a JSON list.
  ///
  /// Useful for parsing API responses that return a list of goals.
  static List<GroupGoalModel> fromJsonList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) {
      return [];
    }
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(GroupGoalModel.fromJson)
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

  /// Safely parses a DateTime from various types.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
