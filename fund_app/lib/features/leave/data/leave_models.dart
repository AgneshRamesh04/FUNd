class LeaveEntry {
  final String id;
  final String userId;
  final String? tripId;
  final String description;
  final int daysUsed;
  final DateTime leaveDate;

  LeaveEntry({
    required this.id,
    required this.userId,
    this.tripId,
    required this.description,
    required this.daysUsed,
    required this.leaveDate,
  });

  factory LeaveEntry.fromJson(Map<String, dynamic> json) {
    return LeaveEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tripId: json['trip_id'] as String?,
      description: json['description'] as String,
      daysUsed: json['days_used'] as int,
      leaveDate: DateTime.parse(json['leave_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'trip_id': tripId,
      'description': description,
      'days_used': daysUsed,
      'leave_date': leaveDate.toIso8601String(),
    };
  }
}

class LeaveTracking {
  final String id;
  final String userId;
  final int used;
  final int total;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveTracking({
    required this.id,
    required this.userId,
    required this.used,
    required this.total,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveTracking.fromJson(Map<String, dynamic> json) {
    return LeaveTracking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      used: json['used'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      year: json['year'] as int,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'used': used, 'total': total, 'year': year};
  }

  int get remaining => total - used;
  bool get isExhausted => remaining <= 0;
}

class LeaveSummary {
  final String id;
  final String userId;
  final String username;
  final int used;
  final int total;
  final int year;
  final DateTime updatedAt;

  LeaveSummary({
    required this.id,
    required this.userId,
    required this.username,
    required this.used,
    required this.total,
    required this.year,
    required this.updatedAt,
  });

  factory LeaveSummary.fromJson(Map<String, dynamic> json) {
    return LeaveSummary(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      used: json['used'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      year: json['year'] as int,
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  int get remaining => total - used;
  double get utilizationPercent => total > 0 ? (used / total) * 100 : 0;
}
