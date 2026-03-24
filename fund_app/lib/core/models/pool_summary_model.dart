class PoolSummaryModel {
  final DateTime month;
  final double poolBalance;
  final double monthlyInflow;
  final double monthlyOutflow;

  PoolSummaryModel({
    required this.month,
    required this.poolBalance,
    required this.monthlyInflow,
    required this.monthlyOutflow,
  });

  factory PoolSummaryModel.fromMap(Map<String, dynamic> data) {
    return PoolSummaryModel(
      month: DateTime.parse(data['month'] as String),
      poolBalance: (data['pool_balance'] as num).toDouble(),
      monthlyInflow: (data['monthly_inflow'] as num).toDouble(),
      monthlyOutflow: (data['monthly_outflow'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month.toIso8601String(),
      'pool_balance': poolBalance,
      'monthly_inflow': monthlyInflow,
      'monthly_outflow': monthlyOutflow,
    };
  }

  PoolSummaryModel copyWith({
    DateTime? month,
    double? poolBalance,
    double? monthlyInflow,
    double? monthlyOutflow,
  }) {
    return PoolSummaryModel(
      month: month ?? this.month,
      poolBalance: poolBalance ?? this.poolBalance,
      monthlyInflow: monthlyInflow ?? this.monthlyInflow,
      monthlyOutflow: monthlyOutflow ?? this.monthlyOutflow,
    );
  }
}
