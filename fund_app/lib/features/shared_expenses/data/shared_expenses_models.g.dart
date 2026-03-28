// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_expenses_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharedTransactionImpl _$$SharedTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$SharedTransactionImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String?,
  date: DateTime.parse(json['date'] as String),
  notes: json['notes'] as String?,
  monthKey: json['month_key'] as String?,
);

Map<String, dynamic> _$$SharedTransactionImplToJson(
  _$SharedTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'type': instance.type,
  'amount': instance.amount,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
  'notes': instance.notes,
  'month_key': instance.monthKey,
};

_$TripSummaryImpl _$$TripSummaryImplFromJson(Map<String, dynamic> json) =>
    _$TripSummaryImpl(
      tripId: json['trip_id'] as String?,
      tripName: json['trip_name'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      durationDays: (json['duration_days'] as num?)?.toInt(),
      totalExpense: (json['total_expense'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$TripSummaryImplToJson(_$TripSummaryImpl instance) =>
    <String, dynamic>{
      'trip_id': instance.tripId,
      'trip_name': instance.tripName,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'duration_days': instance.durationDays,
      'total_expense': instance.totalExpense,
    };
