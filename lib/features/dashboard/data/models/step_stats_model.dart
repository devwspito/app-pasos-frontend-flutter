/// Step stats model for the data layer.
///
/// This file contains the data model for StepStats, extending the domain entity
/// and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_stats.dart';

/// Data model extending [StepStats] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   'today': 5000,
///   'week': 35000,
///   'month': 150000,
///   'allTime': 1500000
/// };
/// final model = StepStatsModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class StepStatsModel extends StepStats {
  /// Creates a [StepStatsModel] instance.
  const StepStatsModel({
    required super.today,
    required super.week,
    required super.month,
    required super.allTime,
  });

  /// Creates a [StepStatsModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "today": 5000,
  ///   "week": 35000,
  ///   "month": 150000,
  ///   "allTime": 1500000
  /// }
  /// ```
  factory StepStatsModel.fromJson(Map<String, dynamic> json) {
    return StepStatsModel(
      today: _parseInt(json['today']),
      week: _parseInt(json['week']),
      month: _parseInt(json['month']),
      allTime: _parseInt(json['allTime'] ?? json['all_time']),
    );
  }

  /// Creates a [StepStatsModel] from a domain [StepStats] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory StepStatsModel.fromEntity(StepStats stats) {
    return StepStatsModel(
      today: stats.today,
      week: stats.week,
      month: stats.month,
      allTime: stats.allTime,
    );
  }

  /// Creates an empty [StepStatsModel] for initial states.
  factory StepStatsModel.empty() => const StepStatsModel(
        today: 0,
        week: 0,
        month: 0,
        allTime: 0,
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'today': today,
      'week': week,
      'month': month,
      'allTime': allTime,
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  StepStatsModel copyWith({
    int? today,
    int? week,
    int? month,
    int? allTime,
  }) {
    return StepStatsModel(
      today: today ?? this.today,
      week: week ?? this.week,
      month: month ?? this.month,
      allTime: allTime ?? this.allTime,
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
