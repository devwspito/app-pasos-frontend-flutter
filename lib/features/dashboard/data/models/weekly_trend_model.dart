/// Weekly trend model for the data layer.
///
/// This file contains the data model for WeeklyTrend, extending the domain entity
/// and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/weekly_trend.dart';

/// Data model extending [WeeklyTrend] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   'date': '2024-01-15',
///   'total': 8500
/// };
/// final model = WeeklyTrendModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class WeeklyTrendModel extends WeeklyTrend {
  /// Creates a [WeeklyTrendModel] instance.
  const WeeklyTrendModel({
    required super.date,
    required super.total,
  });

  /// Creates a [WeeklyTrendModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "date": "2024-01-15",
  ///   "total": 8500
  /// }
  /// ```
  factory WeeklyTrendModel.fromJson(Map<String, dynamic> json) {
    return WeeklyTrendModel(
      date: json['date'] as String? ?? '',
      total: _parseInt(json['total']),
    );
  }

  /// Creates a [WeeklyTrendModel] from a domain [WeeklyTrend] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory WeeklyTrendModel.fromEntity(WeeklyTrend trend) {
    return WeeklyTrendModel(
      date: trend.date,
      total: trend.total,
    );
  }

  /// Creates an empty [WeeklyTrendModel] for initial states.
  factory WeeklyTrendModel.empty() => const WeeklyTrendModel(
        date: '',
        total: 0,
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total': total,
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  WeeklyTrendModel copyWith({
    String? date,
    int? total,
  }) {
    return WeeklyTrendModel(
      date: date ?? this.date,
      total: total ?? this.total,
    );
  }

  /// Parses a list of [WeeklyTrendModel] from a JSON list.
  ///
  /// [jsonList] - The JSON list from the API response.
  ///
  /// Returns an empty list if [jsonList] is null or not a list.
  static List<WeeklyTrendModel> fromJsonList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) {
      return [];
    }

    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(WeeklyTrendModel.fromJson)
        .toList();
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
