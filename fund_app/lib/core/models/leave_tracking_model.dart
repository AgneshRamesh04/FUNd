class LeaveTrackingModel {
  final String id;
  final String userId;
  final int used;
  final int total;
  final int year;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveTrackingModel({
    required this.id,
    required this.userId,
    required this.used,
    required this.total,
    required this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveTrackingModel.fromMap(Map<String, dynamic> data) {
    return LeaveTrackingModel(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      used: data['used'] as int,
      total: data['total'] as int,
      year: data['year'] as int,
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at'] as String) : null,
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'used': used,
      'total': total,
      'year': year,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  int get remaining => total - used;

  LeaveTrackingModel copyWith({
    String? id,
    String? userId,
    int? used,
    int? total,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveTrackingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      used: used ?? this.used,
      total: total ?? this.total,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
