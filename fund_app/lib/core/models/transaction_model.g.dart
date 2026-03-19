// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  paidBy: json['paid_by'] as String,
  receivedBy: json['received_by'] as String?,
  splitType: $enumDecodeNullable(_$SplitTypeEnumMap, json['split_type']),
  splitData: json['split_data'] as Map<String, dynamic>?,
  date: DateTime.parse(json['date'] as String),
  tripId: json['trip_id'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'amount': instance.amount,
      'paid_by': instance.paidBy,
      'received_by': instance.receivedBy,
      'split_type': _$SplitTypeEnumMap[instance.splitType],
      'split_data': instance.splitData,
      'date': instance.date.toIso8601String(),
      'trip_id': instance.tripId,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.borrow: 'borrow',
  TransactionType.deposit: 'deposit',
  TransactionType.sharedExpense: 'shared_expense',
  TransactionType.poolExpense: 'pool_expense',
};

const _$SplitTypeEnumMap = {
  SplitType.equal: 'equal',
  SplitType.custom: 'custom',
};
