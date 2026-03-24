class UserDebtsModel {
  final String userId;
  final double userDebts; // Negative if pool owes user, Positive if user owes pool

  UserDebtsModel({
    required this.userId,
    required this.userDebts,
  });

  factory UserDebtsModel.fromMap(Map<String, dynamic> data) {
    return UserDebtsModel(
      userId: data['user_id'] as String,
      userDebts: (data['user_debts'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_debts': userDebts,
    };
  }

  UserDebtsModel copyWith({
    String? userId,
    double? userDebts,
  }) {
    return UserDebtsModel(
      userId: userId ?? this.userId,
      userDebts: userDebts ?? this.userDebts,
    );
  }
}
