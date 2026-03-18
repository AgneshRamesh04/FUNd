import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction_entity.dart';

part 'transaction_model.g.dart';

/// Transaction model - data layer (maps from/to API)
@JsonSerializable()
class TransactionModel {
  final String id;
  final String type;
  final String description;
  final double amount;
  final String paidBy;
  final String receivedBy;
  final String splitType;
  final Map<String, dynamic>? splitData;
  final String date;
  final String? tripId;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.receivedBy,
    required this.splitType,
    this.splitData,
    required this.date,
    this.tripId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  /// Convert model to entity
  TransactionEntity toEntity() => TransactionEntity(
        id: id,
        type: _parseTransactionType(type),
        description: description,
        amount: amount,
        paidBy: paidBy,
        receivedBy: receivedBy,
        splitType: _parseSplitType(splitType),
        splitData: splitData,
        date: DateTime.parse(date),
        tripId: tripId,
        notes: notes,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );

  /// Convert entity to model
  static TransactionModel fromEntity(TransactionEntity entity) =>
      TransactionModel(
        id: entity.id,
        type: _transactionTypeToString(entity.type),
        description: entity.description,
        amount: entity.amount,
        paidBy: entity.paidBy,
        receivedBy: entity.receivedBy,
        splitType: _splitTypeToString(entity.splitType),
        splitData: entity.splitData,
        date: entity.date.toIso8601String(),
        tripId: entity.tripId,
        notes: entity.notes,
        createdAt: entity.createdAt.toIso8601String(),
        updatedAt: entity.updatedAt.toIso8601String(),
      );

  static TransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'borrow':
        return TransactionType.borrow;
      case 'deposit':
        return TransactionType.deposit;
      case 'shared_expense':
        return TransactionType.sharedExpense;
      case 'pool_expense':
        return TransactionType.poolExpense;
      default:
        return TransactionType.borrow;
    }
  }

  static String _transactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.borrow:
        return 'borrow';
      case TransactionType.deposit:
        return 'deposit';
      case TransactionType.sharedExpense:
        return 'shared_expense';
      case TransactionType.poolExpense:
        return 'pool_expense';
    }
  }

  static SplitType _parseSplitType(String type) {
    switch (type) {
      case 'equal':
        return SplitType.equal;
      case 'custom':
        return SplitType.custom;
      default:
        return SplitType.equal;
    }
  }

  static String _splitTypeToString(SplitType type) {
    switch (type) {
      case SplitType.equal:
        return 'equal';
      case SplitType.custom:
        return 'custom';
    }
  }
}
