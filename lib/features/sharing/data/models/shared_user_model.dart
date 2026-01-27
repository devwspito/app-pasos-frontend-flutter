/// Shared user model for the data layer.
///
/// This file contains the data model for SharedUser, extending the domain
/// entity and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';

/// Data model extending [SharedUser] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   '_id': '123',
///   'name': 'John Doe',
///   'email': 'john@example.com',
///   'avatarUrl': 'https://example.com/avatar.jpg',
///   'todaySteps': 5000,
/// };
/// final model = SharedUserModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class SharedUserModel extends SharedUser {
  /// Creates a [SharedUserModel] instance.
  const SharedUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    super.todaySteps,
  });

  /// Creates a [SharedUserModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "_id": "123",
  ///   "name": "John Doe",
  ///   "email": "john@example.com",
  ///   "avatarUrl": "https://example.com/avatar.jpg",
  ///   "todaySteps": 5000
  /// }
  /// ```
  factory SharedUserModel.fromJson(Map<String, dynamic> json) {
    return SharedUserModel(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      todaySteps: _parseInt(json['todaySteps']),
    );
  }

  /// Creates a [SharedUserModel] from a domain [SharedUser] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory SharedUserModel.fromEntity(SharedUser user) {
    return SharedUserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
      todaySteps: user.todaySteps,
    );
  }

  /// Creates an empty [SharedUserModel] for initial states.
  factory SharedUserModel.empty() => const SharedUserModel(
        id: '',
        name: '',
        email: '',
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (todaySteps != null) 'todaySteps': todaySteps,
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  SharedUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? todaySteps,
  }) {
    return SharedUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      todaySteps: todaySteps ?? this.todaySteps,
    );
  }

  /// Creates a list of [SharedUserModel] from a JSON list.
  ///
  /// Useful for parsing API responses that return a list of users.
  static List<SharedUserModel> fromJsonList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) {
      return [];
    }
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(SharedUserModel.fromJson)
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
}
