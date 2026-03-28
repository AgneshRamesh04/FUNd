import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/date_utils.dart';

part 'shared_expenses_models.freezed.dart';
part 'shared_expenses_models.g.dart';

@freezed
class SharedTransaction with _$SharedTransaction {
  const SharedTransaction._();

  const factory SharedTransaction({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String type, // 'user_paid_for_pool' | 'pool_expense'
    required double amount,
    String? description,
    required DateTime date,
    String? notes,
    @JsonKey(name: 'month_key') String? monthKey,
  }) = _SharedTransaction;

  factory SharedTransaction.fromJson(Map<String, dynamic> json) =>
      _$SharedTransactionFromJson(json);

  String get resolvedMonthKey {
    if (monthKey != null && monthKey!.isNotEmpty) return monthKey!;
    return DateUtils.toMonthKey(date);
  }
}

enum TripStatus { ongoing, upcoming, past }

@freezed
class TripSummary with _$TripSummary {
  const TripSummary._();

  const factory TripSummary({
    @JsonKey(name: 'trip_id') String? tripId,
    @JsonKey(name: 'trip_name') String? tripName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'total_expense') double? totalExpense,
  }) = _TripSummary;

  factory TripSummary.fromJson(Map<String, dynamic> json) =>
      _$TripSummaryFromJson(json);

  TripStatus get status {
    if (startDate == null) return TripStatus.past;
    final today = DateUtils.startOfDay(DateTime.now());
    if (!startDate!.isAfter(today) &&
        (endDate == null || !endDate!.isBefore(today))) {
      return TripStatus.ongoing;
    }
    if (startDate!.isAfter(today)) return TripStatus.upcoming;
    return TripStatus.past;
  }
}
