import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_models.freezed.dart';
part 'home_models.g.dart';

@freezed
class UserDebt with _$UserDebt {
  const factory UserDebt({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'username') required String userName,
    @JsonKey(name: 'debt') required double amount,
  }) = _UserDebt;

  factory UserDebt.fromJson(Map<String, dynamic> json) =>
      _$UserDebtFromJson(json);
}

@freezed
class Debt with _$Debt {
  const factory Debt({
    required String? userId,
    required String userName,
    required double amount,
  }) = _Debt;

  factory Debt.fromJson(Map<String, dynamic> json) => _$DebtFromJson(json);
}

@freezed
class UserLeave with _$UserLeave {
  const factory UserLeave({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'username') required String userName,
    required int used,
    required int total,
    required int year,
  }) = _UserLeave;

  factory UserLeave.fromJson(Map<String, dynamic> json) =>
      _$UserLeaveFromJson(json);
}

class MonthlyFlowTransaction {
  final String id;
  final String type;
  final double amount;
  final String? description;
  final DateTime date;
  final String? userId;

  MonthlyFlowTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.description,
    this.userId,
  });

  factory MonthlyFlowTransaction.fromJson(Map<String, dynamic> json) {
    return MonthlyFlowTransaction(
      id: (json['id'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      userId: json['user_id'] as String?,
    );
  }

  bool get isInflow => type == 'deposit' || type == 'user_paid_for_pool';
}
