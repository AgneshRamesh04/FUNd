// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDebtImpl _$$UserDebtImplFromJson(Map<String, dynamic> json) =>
    _$UserDebtImpl(
      userId: json['user_id'] as String,
      userName: json['username'] as String,
      amount: (json['debt'] as num).toDouble(),
    );

Map<String, dynamic> _$$UserDebtImplToJson(_$UserDebtImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.userName,
      'debt': instance.amount,
    };

_$DebtImpl _$$DebtImplFromJson(Map<String, dynamic> json) => _$DebtImpl(
  userName: json['userName'] as String,
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$$DebtImplToJson(_$DebtImpl instance) =>
    <String, dynamic>{'userName': instance.userName, 'amount': instance.amount};

_$UserLeaveImpl _$$UserLeaveImplFromJson(Map<String, dynamic> json) =>
    _$UserLeaveImpl(
      userId: json['user_id'] as String,
      userName: json['username'] as String,
      used: (json['used'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      year: (json['year'] as num).toInt(),
    );

Map<String, dynamic> _$$UserLeaveImplToJson(_$UserLeaveImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.userName,
      'used': instance.used,
      'total': instance.total,
      'year': instance.year,
    };
