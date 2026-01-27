/// User model for the data layer.
///
/// This file contains the data model for User, extending the domain entity
/// and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';

/// Data model extending [User] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {'id': '123', 'email': 'test@example.com', 'name': 'Test'};
/// final userModel = UserModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = userModel.toJson();
/// ```
class UserModel extends User {
  /// Creates a [UserModel] instance.
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.createdAt,
  });

  /// Creates a [UserModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "id": "string",
  ///   "email": "string",
  ///   "name": "string",
  ///   "createdAt": "2024-01-01T00:00:00.000Z" // optional
  /// }
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// Creates a [UserModel] from a domain [User] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      createdAt: user.createdAt,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
