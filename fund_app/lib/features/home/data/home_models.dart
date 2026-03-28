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
