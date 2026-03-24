class TripSummaryModel {
  final String tripId;
  final String tripName;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final double totalExpense;

  TripSummaryModel({
    required this.tripId,
    required this.tripName,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.totalExpense,
  });

  factory TripSummaryModel.fromMap(Map<String, dynamic> data) {
    return TripSummaryModel(
      tripId: data['trip_id'] as String,
      tripName: data['trip_name'] as String,
      startDate: DateTime.parse(data['start_date'] as String),
      endDate: DateTime.parse(data['end_date'] as String),
      durationDays: data['duration_days'] as int,
      totalExpense: (data['total_expense'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trip_id': tripId,
      'trip_name': tripName,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'duration_days': durationDays,
      'total_expense': totalExpense,
    };
  }

  TripSummaryModel copyWith({
    String? tripId,
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    double? totalExpense,
  }) {
    return TripSummaryModel(
      tripId: tripId ?? this.tripId,
      tripName: tripName ?? this.tripName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      totalExpense: totalExpense ?? this.totalExpense,
    );
  }
}
