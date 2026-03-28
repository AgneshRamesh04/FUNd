class PersonalTransaction {
  final String id;
  final String userId;
  final String type; // 'borrow' | 'monthly_obligation' | 'deposit'
  final double amount;
  final String? description;
  final DateTime date;
  final String? notes;
  final String? monthKey;

  PersonalTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
    this.notes,
    this.monthKey,
  });

  factory PersonalTransaction.fromJson(Map<String, dynamic> json) {
    return PersonalTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      monthKey: json['month_key'] as String?,
    );
  }

  /// Falls back to computing from [date] if [monthKey] is absent.
  String get resolvedMonthKey {
    if (monthKey != null && monthKey!.isNotEmpty) return monthKey!;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
}
