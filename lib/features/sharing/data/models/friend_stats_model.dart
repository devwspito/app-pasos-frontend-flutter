/// Friend stats model for the data layer.
///
/// This file contains the data model for FriendStats, extending the domain
/// entity and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/friend_stats.dart';

/// Data model extending [FriendStats] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   'userId': '123',
///   'todaySteps': 5000,
///   'weekSteps': 35000,
///   'monthSteps': 150000,
///   'allTimeSteps': 1500000,
/// };
/// final model = FriendStatsModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class FriendStatsModel extends FriendStats {
  /// Creates a [FriendStatsModel] instance.
  const FriendStatsModel({
    required super.userId,
    required super.todaySteps,
    required super.weekSteps,
    required super.monthSteps,
    required super.allTimeSteps,
  });

  /// Creates a [FriendStatsModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "userId": "123",
  ///   "todaySteps": 5000,
  ///   "weekSteps": 35000,
  ///   "monthSteps": 150000,
  ///   "allTimeSteps": 1500000
  /// }
  /// ```
  factory FriendStatsModel.fromJson(Map<String, dynamic> json) {
    return FriendStatsModel(
      userId: json['userId'] as String? ?? json['_id'] as String? ?? '',
      todaySteps: _parseInt(json['todaySteps'] ?? json['today']),
      weekSteps: _parseInt(json['weekSteps'] ?? json['week']),
      monthSteps: _parseInt(json['monthSteps'] ?? json['month']),
      allTimeSteps: _parseInt(json['allTimeSteps'] ?? json['allTime']),
    );
  }

  /// Creates a [FriendStatsModel] from a domain [FriendStats] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory FriendStatsModel.fromEntity(FriendStats stats) {
    return FriendStatsModel(
      userId: stats.userId,
      todaySteps: stats.todaySteps,
      weekSteps: stats.weekSteps,
      monthSteps: stats.monthSteps,
      allTimeSteps: stats.allTimeSteps,
    );
  }

  /// Creates an empty [FriendStatsModel] for initial states.
  factory FriendStatsModel.empty() => const FriendStatsModel(
        userId: '',
        todaySteps: 0,
        weekSteps: 0,
        monthSteps: 0,
        allTimeSteps: 0,
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'todaySteps': todaySteps,
      'weekSteps': weekSteps,
      'monthSteps': monthSteps,
      'allTimeSteps': allTimeSteps,
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  FriendStatsModel copyWith({
    String? userId,
    int? todaySteps,
    int? weekSteps,
    int? monthSteps,
    int? allTimeSteps,
  }) {
    return FriendStatsModel(
      userId: userId ?? this.userId,
      todaySteps: todaySteps ?? this.todaySteps,
      weekSteps: weekSteps ?? this.weekSteps,
      monthSteps: monthSteps ?? this.monthSteps,
      allTimeSteps: allTimeSteps ?? this.allTimeSteps,
    );
  }

  /// Safely parses an integer from various types.
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
