class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final double monthlyObligation;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.monthlyObligation = 0.0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      monthlyObligation: (data['monthly_obligation'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'monthly_obligation': monthlyObligation,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    double? monthlyObligation,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      monthlyObligation: monthlyObligation ?? this.monthlyObligation,
    );
  }
}
