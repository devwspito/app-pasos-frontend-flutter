/// Sharing relationship model for the data layer.
///
/// This file contains the data model for SharingRelationship, extending the
/// domain entity and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';

/// Data model extending [SharingRelationship] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   '_id': '123',
///   'fromUserId': 'user1',
///   'toUserId': 'user2',
///   'status': 'pending',
///   'createdAt': '2024-01-01T00:00:00.000Z',
/// };
/// final model = SharingRelationshipModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = model.toJson();
/// ```
class SharingRelationshipModel extends SharingRelationship {
  /// Creates a [SharingRelationshipModel] instance.
  const SharingRelationshipModel({
    required super.id,
    required super.fromUserId,
    required super.toUserId,
    required super.status,
    required super.createdAt,
    super.acceptedAt,
  });

  /// Creates a [SharingRelationshipModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "_id": "123",
  ///   "fromUserId": "user1",
  ///   "toUserId": "user2",
  ///   "status": "pending",
  ///   "createdAt": "2024-01-01T00:00:00.000Z",
  ///   "acceptedAt": "2024-01-02T00:00:00.000Z"
  /// }
  /// ```
  factory SharingRelationshipModel.fromJson(Map<String, dynamic> json) {
    return SharingRelationshipModel(
      id: json['_id'] as String? ?? json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
    );
  }

  /// Creates a [SharingRelationshipModel] from a domain
  /// [SharingRelationship] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory SharingRelationshipModel.fromEntity(
    SharingRelationship relationship,
  ) {
    return SharingRelationshipModel(
      id: relationship.id,
      fromUserId: relationship.fromUserId,
      toUserId: relationship.toUserId,
      status: relationship.status,
      createdAt: relationship.createdAt,
      acceptedAt: relationship.acceptedAt,
    );
  }

  /// Creates an empty [SharingRelationshipModel] for initial states.
  factory SharingRelationshipModel.empty() => SharingRelationshipModel(
        id: '',
        fromUserId: '',
        toUserId: '',
        status: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt!.toIso8601String(),
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  SharingRelationshipModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return SharingRelationshipModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }

  /// Creates a list of [SharingRelationshipModel] from a JSON list.
  ///
  /// Useful for parsing API responses that return a list of relationships.
  static List<SharingRelationshipModel> fromJsonList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) {
      return [];
    }
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(SharingRelationshipModel.fromJson)
        .toList();
  }
}
