// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_tracking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveTracking _$LeaveTrackingFromJson(Map<String, dynamic> json) =>
    LeaveTracking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      used: (json['used'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LeaveTrackingToJson(LeaveTracking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'used': instance.used,
      'balance': instance.balance,
      'month': instance.month,
      'year': instance.year,
      'created_at': instance.createdAt.toIso8601String(),
    };
