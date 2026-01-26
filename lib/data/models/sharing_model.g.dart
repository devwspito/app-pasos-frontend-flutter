// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharingModel _$SharingModelFromJson(Map<String, dynamic> json) => SharingModel(
      id: json['_id'] as String,
      requesterId: json['requesterId'] as String,
      targetId: json['targetId'] as String,
      status: $enumDecode(_$SharingStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
    );

Map<String, dynamic> _$SharingModelToJson(SharingModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'requesterId': instance.requesterId,
      'targetId': instance.targetId,
      'status': _$SharingStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
    };

const _$SharingStatusEnumMap = {
  SharingStatus.pending: 'pending',
  SharingStatus.accepted: 'accepted',
  SharingStatus.bidirectional: 'bidirectional',
  SharingStatus.rejected: 'rejected',
};
