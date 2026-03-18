import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// User entity
@JsonSerializable()
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [id, name, email, createdAt];
}

/// Transaction entity
@JsonSerializable()
class Transaction extends Equatable {
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

  const Transaction({
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

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

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

/// Trip entity
@JsonSerializable()
class Trip extends Equatable {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const Trip({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  Map<String, dynamic> toJson() => _$TripToJson(this);

  @override
  List<Object?> get props => [id, name, startDate, endDate, createdAt];
}

/// Leave tracking entity
@JsonSerializable()
class LeaveTracking extends Equatable {
  final String id;
  final String userId;
  final double used;
  final double balance;
  final int month;
  final int year;

  const LeaveTracking({
    required this.id,
    required this.userId,
    required this.used,
    required this.balance,
    required this.month,
    required this.year,
  });

  factory LeaveTracking.fromJson(Map<String, dynamic> json) =>
      _$LeaveTrackingFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveTrackingToJson(this);

  @override
  List<Object?> get props => [id, userId, used, balance, month, year];
}

/// Transaction type enum
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

/// Split type enum
enum SplitType {
  @JsonValue('equal')
  equal,
  @JsonValue('custom')
  custom,
}

/// Financial summary for monthly overview
class MonthlySummary extends Equatable {
  final double poolBalance;
  final double inflow;
  final double outflow;
  final Map<String, double> userDebts;

  const MonthlySummary({
    required this.poolBalance,
    required this.inflow,
    required this.outflow,
    required this.userDebts,
  });

  @override
  List<Object?> get props => [poolBalance, inflow, outflow, userDebts];
}

/// Trip summary
class TripSummary extends Equatable {
  final Trip trip;
  final List<Transaction> expenses;
  final Map<String, double> contributions;
  final double totalCost;

  TripSummary({
    required this.trip,
    required this.expenses,
    required this.contributions,
    required this.totalCost,
  });

  @override
  List<Object?> get props => [trip, expenses, contributions, totalCost];
}
