class TransactionModel {
  final String id;
  final String type; // 'borrow', 'deposit', 'shared_expense', 'pool_expense'
  final String? userId;
  final String? description;
  final double amount;
  final DateTime date;
  final String? notes;
  final DateTime? createdAt;
  final String? tripId;
  final String? monthKey; // e.g., "2026-03"

  TransactionModel({
    required this.id,
    required this.type,
    this.userId,
    this.description,
    required this.amount,
    required this.date,
    this.notes,
    this.createdAt,
    this.tripId,
    this.monthKey,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id'] as String,
      type: data['type'] as String,
      userId: data['user_id'] as String?,
      description: data['description'] as String?,
      amount: (data['amount'] as num).toDouble(),
      date: DateTime.parse(data['date'] as String),
      notes: data['notes'] as String?,
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at'] as String) : null,
      tripId: data['trip_id'] as String?,
      monthKey: data['month_key'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'user_id': userId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'trip_id': tripId,
      'month_key': monthKey,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? type,
    String? userId,
    String? description,
    double? amount,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    String? tripId,
    String? monthKey,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      tripId: tripId ?? this.tripId,
      monthKey: monthKey ?? this.monthKey,
    );
  }
}
