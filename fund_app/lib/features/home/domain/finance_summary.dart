class FinanceSummary {
  final double poolBalance;
  final double inflow;
  final double outflow;
  final double userADebt;
  final double userBDebt;
  final List<double> inflowGraph;
  final List<double> outflowGraph;

  FinanceSummary({
    required this.poolBalance,
    required this.inflow,
    required this.outflow,
    required this.userADebt,
    required this.userBDebt,
    required this.inflowGraph,
    required this.outflowGraph,
  });
}