/// Member contribution model for the data layer.
///
/// This file contains the data model for MemberContribution, extending the
/// domain entity and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/member_contribution.dart';

/// Data model extending [MemberContribution] with JSON serialization.
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
///   'userName': 'John Doe',
///   'totalSteps': 15000,
///   'contributionPercentage': 20.0,
///   'rank': 2,
/// };
/// final model = MemberContributionModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class MemberContributionModel extends MemberContribution {
  /// Creates a [MemberContributionModel] instance.
  const MemberContributionModel({
    required super.id,
    required super.goalId,
    required super.userId,
    required super.userName,
    required super.totalSteps,
    required super.contributionPercentage,
    required super.rank,
  });

  /// Creates a [MemberContributionModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "_id": "123",
  ///   "goalId": "goal456",
  ///   "userId": "user789",
  ///   "userName": "John Doe",
  ///   "totalSteps": 15000,
  ///   "contributionPercentage": 20.0,
  ///   "rank": 2
  /// }
  /// ```
  factory MemberContributionModel.fromJson(Map<String, dynamic> json) {
    return MemberContributionModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      goalId: json['goalId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      totalSteps: _parseInt(json['totalSteps']) ?? 0,
      contributionPercentage:
          _parseDouble(json['contributionPercentage']) ?? 0.0,
      rank: _parseInt(json['rank']) ?? 0,
    );
  }

  /// Creates a [MemberContributionModel] from a domain [MemberContribution]
  /// entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory MemberContributionModel.fromEntity(MemberContribution contribution) {
    return MemberContributionModel(
      id: contribution.id,
      goalId: contribution.goalId,
      userId: contribution.userId,
      userName: contribution.userName,
      totalSteps: contribution.totalSteps,
      contributionPercentage: contribution.contributionPercentage,
      rank: contribution.rank,
    );
  }

  /// Creates an empty [MemberContributionModel] for initial states.
  factory MemberContributionModel.empty() => const MemberContributionModel(
        id: '',
        goalId: '',
        userId: '',
        userName: '',
        totalSteps: 0,
        contributionPercentage: 0,
        rank: 0,
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'userName': userName,
      'totalSteps': totalSteps,
      'contributionPercentage': contributionPercentage,
      'rank': rank,
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  MemberContributionModel copyWith({
    String? id,
    String? goalId,
    String? userId,
    String? userName,
    int? totalSteps,
    double? contributionPercentage,
    int? rank,
  }) {
    return MemberContributionModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      totalSteps: totalSteps ?? this.totalSteps,
      contributionPercentage:
          contributionPercentage ?? this.contributionPercentage,
      rank: rank ?? this.rank,
    );
  }

  /// Creates a list of [MemberContributionModel] from a JSON list.
  ///
  /// Useful for parsing API responses that return a list of contributions.
  static List<MemberContributionModel> fromJsonList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) {
      return [];
    }
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(MemberContributionModel.fromJson)
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
}
