import 'package:json_annotation/json_annotation.dart';

part 'leave_tracking_model.g.dart';

@JsonSerializable()
class LeaveTracking {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final double used;
  final double balance;
  final int month;
  final int year;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  LeaveTracking({
    required this.id,
    required this.userId,
    required this.used,
    required this.balance,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  factory LeaveTracking.fromJson(Map<String, dynamic> json) =>
      _$LeaveTrackingFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveTrackingToJson(this);

  LeaveTracking copyWith({
    String? id,
    String? userId,
    double? used,
    double? balance,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return LeaveTracking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      used: used ?? this.used,
      balance: balance ?? this.balance,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
