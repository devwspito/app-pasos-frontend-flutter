// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepModel _$StepModelFromJson(Map<String, dynamic> json) => StepModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      count: (json['count'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: $enumDecode(_$StepSourceEnumMap, json['source']),
      hour: (json['hour'] as num).toInt(),
      date: json['date'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StepModelToJson(StepModel instance) => <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'count': instance.count,
      'timestamp': instance.timestamp.toIso8601String(),
      'source': _$StepSourceEnumMap[instance.source]!,
      'hour': instance.hour,
      'date': instance.date,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$StepSourceEnumMap = {
  StepSource.native: 'native',
  StepSource.manual: 'manual',
  StepSource.web: 'web',
};
