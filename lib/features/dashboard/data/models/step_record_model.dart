/// Step record model for the data layer.
///
/// This file contains the data model for StepRecord, extending the domain entity
/// and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';

/// Data model extending [StepRecord] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   'id': '123',
///   'userId': 'user-456',
///   'count': 1500,
///   'source': 'native',
///   'date': '2024-01-15',
///   'hour': 14,
///   'timestamp': '2024-01-15T14:30:00.000Z'
/// };
/// final model = StepRecordModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class StepRecordModel extends StepRecord {
  /// Creates a [StepRecordModel] instance.
  const StepRecordModel({
    required super.id,
    required super.userId,
    required super.count,
    required super.source,
    required super.date,
    required super.hour,
    required super.timestamp,
  });

  /// Creates a [StepRecordModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "id": "string",
  ///   "userId": "string",
  ///   "count": 1500,
  ///   "source": "native",
  ///   "date": "2024-01-15",
  ///   "hour": 14,
  ///   "timestamp": "2024-01-15T14:30:00.000Z"
  /// }
  /// ```
  factory StepRecordModel.fromJson(Map<String, dynamic> json) {
    return StepRecordModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      source: _parseStepSource(json['source']),
      date: json['date'] as String? ?? '',
      hour: json['hour'] as int? ?? 0,
      timestamp: _parseTimestamp(json['timestamp'] ?? json['createdAt']),
    );
  }

  /// Creates a [StepRecordModel] from a domain [StepRecord] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory StepRecordModel.fromEntity(StepRecord record) {
    return StepRecordModel(
      id: record.id,
      userId: record.userId,
      count: record.count,
      source: record.source,
      date: record.date,
      hour: record.hour,
      timestamp: record.timestamp,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'count': count,
      'source': _sourceToString(source),
      'date': date,
      'hour': hour,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  StepRecordModel copyWith({
    String? id,
    String? userId,
    int? count,
    StepSource? source,
    String? date,
    int? hour,
    DateTime? timestamp,
  }) {
    return StepRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      count: count ?? this.count,
      source: source ?? this.source,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Parses a [StepSource] from a string value.
  static StepSource _parseStepSource(dynamic value) {
    if (value == null) return StepSource.native;

    final sourceString = value.toString().toLowerCase();
    return switch (sourceString) {
      'native' => StepSource.native,
      'manual' => StepSource.manual,
      'web' => StepSource.web,
      _ => StepSource.native,
    };
  }

  /// Converts a [StepSource] to its string representation.
  static String _sourceToString(StepSource source) {
    return switch (source) {
      StepSource.native => 'native',
      StepSource.manual => 'manual',
      StepSource.web => 'web',
    };
  }

  /// Parses a timestamp from various formats.
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.now();
  }
}
