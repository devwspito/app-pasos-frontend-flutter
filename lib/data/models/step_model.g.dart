// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepModel _$StepModelFromJson(Map<String, dynamic> json) => StepModel(
      id: json['_id'] as String?,
      userId: json['userId'] as String,
      count: (json['count'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: $enumDecode(_$StepSourceEnumMap, json['source']),
      hour: (json['hour'] as num).toInt(),
      date: json['date'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StepModelToJson(StepModel instance) => <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'count': instance.count,
      'timestamp': instance.timestamp.toIso8601String(),
      'source': _$StepSourceEnumMap[instance.source]!,
      'hour': instance.hour,
      'date': instance.date,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$StepSourceEnumMap = {
  StepSource.native: 'native',
  StepSource.manual: 'manual',
  StepSource.web: 'web',
};

TodayStepsResponse _$TodayStepsResponseFromJson(Map<String, dynamic> json) =>
    TodayStepsResponse(
      totalSteps: (json['totalSteps'] as num).toInt(),
      date: json['date'] as String,
    );

Map<String, dynamic> _$TodayStepsResponseToJson(TodayStepsResponse instance) =>
    <String, dynamic>{
      'totalSteps': instance.totalSteps,
      'date': instance.date,
    };

WeeklyTrendResponse _$WeeklyTrendResponseFromJson(Map<String, dynamic> json) =>
    WeeklyTrendResponse(
      days: (json['days'] as List<dynamic>)
          .map((e) => DailySteps.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalSteps: (json['totalSteps'] as num).toInt(),
      averageSteps: (json['averageSteps'] as num).toDouble(),
    );

Map<String, dynamic> _$WeeklyTrendResponseToJson(
        WeeklyTrendResponse instance) =>
    <String, dynamic>{
      'days': instance.days,
      'totalSteps': instance.totalSteps,
      'averageSteps': instance.averageSteps,
    };

DailySteps _$DailyStepsFromJson(Map<String, dynamic> json) => DailySteps(
      date: json['date'] as String,
      totalSteps: (json['totalSteps'] as num).toInt(),
    );

Map<String, dynamic> _$DailyStepsToJson(DailySteps instance) =>
    <String, dynamic>{
      'date': instance.date,
      'totalSteps': instance.totalSteps,
    };
