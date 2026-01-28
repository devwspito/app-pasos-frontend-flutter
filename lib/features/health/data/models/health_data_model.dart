/// Health data model for the data layer.
///
/// This file contains the data model for HealthData, extending the domain entity
/// and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/health/data/models/step_sample_model.dart';
import 'package:app_pasos_frontend/features/health/domain/entities/health_data.dart';
import 'package:app_pasos_frontend/features/health/domain/entities/step_sample.dart';

/// Data model extending [HealthData] with JSON serialization.
///
/// This class serves as a bridge between the health platform data and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From JSON
/// final json = {
///   'totalSteps': 8500,
///   'startDate': '2024-01-15T00:00:00.000Z',
///   'endDate': '2024-01-15T23:59:59.000Z',
///   'samples': [...]
/// };
/// final model = HealthDataModel.fromJson(json);
///
/// // To JSON for storage
/// final storedData = model.toJson();
/// ```
class HealthDataModel extends HealthData {
  /// Creates a [HealthDataModel] instance.
  const HealthDataModel({
    required super.totalSteps,
    required super.startDate,
    required super.endDate,
    required super.samples,
  });

  /// Creates a [HealthDataModel] from a JSON map.
  ///
  /// [json] - The JSON map from stored data or API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "totalSteps": 8500,
  ///   "startDate": "2024-01-15T00:00:00.000Z",
  ///   "endDate": "2024-01-15T23:59:59.000Z",
  ///   "samples": [
  ///     {
  ///       "steps": 250,
  ///       "startTime": "2024-01-15T14:00:00.000Z",
  ///       "endTime": "2024-01-15T14:30:00.000Z",
  ///       "source": "com.apple.health"
  ///     }
  ///   ]
  /// }
  /// ```
  factory HealthDataModel.fromJson(Map<String, dynamic> json) {
    final samplesList = json['samples'] as List<dynamic>? ?? <dynamic>[];
    final samples = samplesList
        .map((sample) =>
            StepSampleModel.fromJson(sample as Map<String, dynamic>))
        .toList();

    return HealthDataModel(
      totalSteps: json['totalSteps'] as int? ?? 0,
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTime(json['endDate']),
      samples: samples,
    );
  }

  /// Creates a [HealthDataModel] from a domain [HealthData] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory HealthDataModel.fromEntity(HealthData healthData) {
    final sampleModels = healthData.samples
        .map((sample) => StepSampleModel.fromEntity(sample))
        .toList();

    return HealthDataModel(
      totalSteps: healthData.totalSteps,
      startDate: healthData.startDate,
      endDate: healthData.endDate,
      samples: sampleModels,
    );
  }

  /// Creates an empty health data model for use in initial states.
  factory HealthDataModel.empty() => HealthDataModel(
        totalSteps: 0,
        startDate: DateTime.fromMillisecondsSinceEpoch(0),
        endDate: DateTime.fromMillisecondsSinceEpoch(0),
        samples: const [],
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for storage or API requests.
  Map<String, dynamic> toJson() {
    return {
      'totalSteps': totalSteps,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'samples': samples
          .map((sample) => StepSampleModel.fromEntity(sample).toJson())
          .toList(),
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  HealthDataModel copyWith({
    int? totalSteps,
    DateTime? startDate,
    DateTime? endDate,
    List<StepSample>? samples,
  }) {
    return HealthDataModel(
      totalSteps: totalSteps ?? this.totalSteps,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      samples: samples ?? this.samples,
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
