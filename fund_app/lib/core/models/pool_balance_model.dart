class PoolBalanceModel {
  final double poolBalance;

  PoolBalanceModel({
    required this.poolBalance,
  });

  factory PoolBalanceModel.fromMap(Map<String, dynamic> data) {
    return PoolBalanceModel(
      poolBalance: (data['pool_balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pool_balance': poolBalance,
    };
  }

  PoolBalanceModel copyWith({
    double? poolBalance,
  }) {
    return PoolBalanceModel(
      poolBalance: poolBalance ?? this.poolBalance,
    );
  }
}
