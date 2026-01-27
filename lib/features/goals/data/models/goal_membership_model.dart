/// Goal membership model for the data layer.
///
/// This file contains the data model for GoalMembership, extending the domain
/// entity and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/goal_membership.dart';

/// Data model extending [GoalMembership] with JSON serialization.
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
///   'userId': 'user789',
///   'role': 'member',
///   'joinedAt': '2024-01-01T00:00:00.000Z',
///   'status': 'active',
/// };
/// final model = GoalMembershipModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class GoalMembershipModel extends GoalMembership {
  /// Creates a [GoalMembershipModel] instance.
  const GoalMembershipModel({
    required super.id,
    required super.goalId,
    required super.userId,
    required super.role,
    required super.joinedAt,
    required super.status,
  });

  /// Creates a [GoalMembershipModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "_id": "123",
  ///   "goalId": "goal456",
  ///   "userId": "user789",
  ///   "role": "member",
  ///   "joinedAt": "2024-01-01T00:00:00.000Z",
  ///   "status": "active"
  /// }
  /// ```
  factory GoalMembershipModel.fromJson(Map<String, dynamic> json) {
    return GoalMembershipModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      goalId: json['goalId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String? ?? '',
      joinedAt: _parseDateTime(json['joinedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: json['status'] as String? ?? '',
    );
  }

  /// Creates a [GoalMembershipModel] from a domain [GoalMembership] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory GoalMembershipModel.fromEntity(GoalMembership membership) {
    return GoalMembershipModel(
      id: membership.id,
      goalId: membership.goalId,
      userId: membership.userId,
      role: membership.role,
      joinedAt: membership.joinedAt,
      status: membership.status,
    );
  }

  /// Creates an empty [GoalMembershipModel] for initial states.
  factory GoalMembershipModel.empty() => GoalMembershipModel(
        id: '',
        goalId: '',
        userId: '',
        role: '',
        joinedAt: DateTime.fromMillisecondsSinceEpoch(0),
        status: '',
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'status': status,
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  GoalMembershipModel copyWith({
    String? id,
    String? goalId,
    String? userId,
    String? role,
    DateTime? joinedAt,
    String? status,
  }) {
    return GoalMembershipModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
    );
  }

  /// Creates a list of [GoalMembershipModel] from a JSON list.
  ///
  /// Useful for parsing API responses that return a list of memberships.
  static List<GoalMembershipModel> fromJsonList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) {
      return [];
    }
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(GoalMembershipModel.fromJson)
        .toList();
  }

  /// Safely parses a DateTime from various types.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
