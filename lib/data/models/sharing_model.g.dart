// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharingRelationshipModel _$SharingRelationshipModelFromJson(
        Map<String, dynamic> json) =>
    SharingRelationshipModel(
      id: json['_id'] as String,
      requesterId: json['requesterId'] as String,
      targetId: json['targetId'] as String,
      status: $enumDecode(_$SharingStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      requester: json['requester'] == null
          ? null
          : UserModel.fromJson(json['requester'] as Map<String, dynamic>),
      target: json['target'] == null
          ? null
          : UserModel.fromJson(json['target'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SharingRelationshipModelToJson(
        SharingRelationshipModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'requesterId': instance.requesterId,
      'targetId': instance.targetId,
      'status': _$SharingStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      if (instance.requester case final value?) 'requester': value,
      if (instance.target case final value?) 'target': value,
    };

const _$SharingStatusEnumMap = {
  SharingStatus.pending: 'pending',
  SharingStatus.accepted: 'accepted',
  SharingStatus.bidirectional: 'bidirectional',
  SharingStatus.rejected: 'rejected',
};

CreateShareRequest _$CreateShareRequestFromJson(Map<String, dynamic> json) =>
    CreateShareRequest(
      targetId: json['targetId'] as String,
    );

Map<String, dynamic> _$CreateShareRequestToJson(CreateShareRequest instance) =>
    <String, dynamic>{
      'targetId': instance.targetId,
    };

PendingSharesResponse _$PendingSharesResponseFromJson(
        Map<String, dynamic> json) =>
    PendingSharesResponse(
      incoming: (json['incoming'] as List<dynamic>)
          .map((e) =>
              SharingRelationshipModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      outgoing: (json['outgoing'] as List<dynamic>)
          .map((e) =>
              SharingRelationshipModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PendingSharesResponseToJson(
        PendingSharesResponse instance) =>
    <String, dynamic>{
      'incoming': instance.incoming,
      'outgoing': instance.outgoing,
    };
