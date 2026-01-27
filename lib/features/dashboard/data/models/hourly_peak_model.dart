/// Hourly peak model for the data layer.
///
/// This file contains the data model for HourlyPeak, extending the domain entity
/// and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/hourly_peak.dart';

/// Data model extending [HourlyPeak] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   'hour': 14,
///   'total': 1200
/// };
/// final model = HourlyPeakModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class HourlyPeakModel extends HourlyPeak {
  /// Creates an [HourlyPeakModel] instance.
  const HourlyPeakModel({
    required super.hour,
    required super.total,
  });

  /// Creates an [HourlyPeakModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "hour": 14,
  ///   "total": 1200
  /// }
  /// ```
  factory HourlyPeakModel.fromJson(Map<String, dynamic> json) {
    return HourlyPeakModel(
      hour: _parseInt(json['hour']),
      total: _parseInt(json['total']),
    );
  }

  /// Creates an [HourlyPeakModel] from a domain [HourlyPeak] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory HourlyPeakModel.fromEntity(HourlyPeak peak) {
    return HourlyPeakModel(
      hour: peak.hour,
      total: peak.total,
    );
  }

  /// Creates an empty [HourlyPeakModel] for initial states.
  factory HourlyPeakModel.empty() => const HourlyPeakModel(
        hour: 0,
        total: 0,
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'total': total,
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  HourlyPeakModel copyWith({
    int? hour,
    int? total,
  }) {
    return HourlyPeakModel(
      hour: hour ?? this.hour,
      total: total ?? this.total,
    );
  }

  /// Parses a list of [HourlyPeakModel] from a JSON list.
  ///
  /// [jsonList] - The JSON list from the API response.
  ///
  /// Returns an empty list if [jsonList] is null or not a list.
  static List<HourlyPeakModel> fromJsonList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) {
      return [];
    }

    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(HourlyPeakModel.fromJson)
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
