import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

enum TransactionType {
  @JsonValue('borrow')
  borrow,
  @JsonValue('deposit')
  deposit,
  @JsonValue('shared_expense')
  sharedExpense,
  @JsonValue('pool_expense')
  poolExpense,
}

enum SplitType {
  @JsonValue('equal')
  equal,
  @JsonValue('custom')
  custom,
}

@JsonSerializable()
class Transaction {
  final String id;
  final TransactionType type;
  final String description;
  final double amount;
  @JsonKey(name: 'paid_by')
  final String paidBy;
  @JsonKey(name: 'received_by')
  final String? receivedBy;
  @JsonKey(name: 'split_type')
  final SplitType? splitType;
  @JsonKey(name: 'split_data')
  final Map<String, dynamic>? splitData;
  final DateTime date;
  @JsonKey(name: 'trip_id')
  final String? tripId;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.paidBy,
    this.receivedBy,
    this.splitType,
    this.splitData,
    required this.date,
    this.tripId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  Transaction copyWith({
    String? id,
    TransactionType? type,
    String? description,
    double? amount,
    String? paidBy,
    String? receivedBy,
    SplitType? splitType,
    Map<String, dynamic>? splitData,
    DateTime? date,
    String? tripId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      receivedBy: receivedBy ?? this.receivedBy,
      splitType: splitType ?? this.splitType,
      splitData: splitData ?? this.splitData,
      date: date ?? this.date,
      tripId: tripId ?? this.tripId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
