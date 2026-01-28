/// Step sample model for the data layer.
///
/// This file contains the data model for StepSample, extending the domain entity
/// and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/health/domain/entities/step_sample.dart';

/// Data model extending [StepSample] with JSON serialization.
///
/// This class serves as a bridge between the health platform data and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From JSON
/// final json = {
///   'steps': 250,
///   'startTime': '2024-01-15T14:00:00.000Z',
///   'endTime': '2024-01-15T14:30:00.000Z',
///   'source': 'com.apple.health',
/// };
/// final model = StepSampleModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class StepSampleModel extends StepSample {
  /// Creates a [StepSampleModel] instance.
  const StepSampleModel({
    required super.steps,
    required super.startTime,
    required super.endTime,
    required super.source,
  });

  /// Creates a [StepSampleModel] from a JSON map.
  ///
  /// [json] - The JSON map from the health platform data.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "steps": 250,
  ///   "startTime": "2024-01-15T14:00:00.000Z",
  ///   "endTime": "2024-01-15T14:30:00.000Z",
  ///   "source": "com.apple.health"
  /// }
  /// ```
  factory StepSampleModel.fromJson(Map<String, dynamic> json) {
    return StepSampleModel(
      steps: json['steps'] as int? ?? 0,
      startTime: _parseDateTime(json['startTime']),
      endTime: _parseDateTime(json['endTime']),
      source: json['source'] as String? ?? '',
    );
  }

  /// Creates a [StepSampleModel] from a domain [StepSample] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory StepSampleModel.fromEntity(StepSample sample) {
    return StepSampleModel(
      steps: sample.steps,
      startTime: sample.startTime,
      endTime: sample.endTime,
      source: sample.source,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for storage or API requests.
  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'source': source,
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  StepSampleModel copyWith({
    int? steps,
    DateTime? startTime,
    DateTime? endTime,
    String? source,
  }) {
    return StepSampleModel(
      steps: steps ?? this.steps,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      source: source ?? this.source,
    );
  }

  /// Parses a DateTime from various formats.
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
