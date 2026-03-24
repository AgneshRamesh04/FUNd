class TripModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? createdAt;

  TripModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.createdAt,
  });

  factory TripModel.fromMap(Map<String, dynamic> data) {
    return TripModel(
      id: data['id'] as String,
      name: data['name'] as String,
      startDate: DateTime.parse(data['start_date'] as String),
      endDate: DateTime.parse(data['end_date'] as String),
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  TripModel copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
