import 'package:equatable/equatable.dart';

/// Transaction entity - domain layer (business logic)
class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final String description;
  final double amount;
  final String paidBy;
  final String receivedBy;
  final SplitType splitType;
  final Map<String, dynamic>? splitData;
  final DateTime date;
  final String? tripId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
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

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        amount,
        paidBy,
        receivedBy,
        splitType,
        splitData,
        date,
        tripId,
        notes,
        createdAt,
        updatedAt,
      ];
}

/// Transaction type enum
enum TransactionType {
  borrow,
  deposit,
  sharedExpense,
  poolExpense,
}

/// Split type enum
enum SplitType {
  equal,
  custom,
}

/// Financial summary entity
class MonthlySummaryEntity extends Equatable {
  final double poolBalance;
  final double inflow;
  final double outflow;
  final Map<String, double> userDebts;

  const MonthlySummaryEntity({
    required this.poolBalance,
    required this.inflow,
    required this.outflow,
    required this.userDebts,
  });

  @override
  List<Object?> get props => [poolBalance, inflow, outflow, userDebts];
}

/// Trip summary entity
class TripSummaryEntity extends Equatable {
  final String tripId;
  final String tripName;
  final List<TransactionEntity> expenses;
  final Map<String, double> contributions;
  final double totalCost;

  const TripSummaryEntity({
    required this.tripId,
    required this.tripName,
    required this.expenses,
    required this.contributions,
    required this.totalCost,
  });

  @override
  List<Object?> get props => [tripId, tripName, expenses, contributions, totalCost];
}

/// Settlement entity
class SettlementEntity extends Equatable {
  final String userId1;
  final String userId2;
  final double amount;

  const SettlementEntity({
    required this.userId1,
    required this.userId2,
    required this.amount,
  });

  @override
  List<Object?> get props => [userId1, userId2, amount];
}
