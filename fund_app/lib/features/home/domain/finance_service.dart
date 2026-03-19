import 'package:intl/intl.dart';

import '../../../core/constants/demo_data.dart';
import 'finance_summary.dart';

class FinanceService {
  static FinanceSummary calculate({
    required List<Map<String, dynamic>> allTransactions,
    required DateTime selectedDate,
  }) {
    double poolBalance = 0.0;
    double userADebt = 0.0;
    double userBDebt = 0.0;

    // Monthly metrics
    double monthlyInflow = 0.0;
    double monthlyOutflow = 0.0;
    List<double> inflowBuckets = List.filled(8, 0.0);
    List<double> outflowBuckets = List.filled(8, 0.0);

    for (var tx in allTransactions) {
      final double amount = (tx['amount'] as num).toDouble();
      final String type = tx['type'];
      final DateTime txDate = DateTime.parse(tx['date']);
      final bool isSameMonth = txDate.month == selectedDate.month && txDate.year == selectedDate.year;

      // 1. LIFETIME CALCULATIONS (Balance & Debt)
      if (type == 'deposit') {
        poolBalance += amount;
        if (tx['paid_by'] == DemoData.userAId) userADebt -= amount;
        if (tx['paid_by'] == DemoData.userBId) userBDebt -= amount;

        if (isSameMonth) {
          monthlyInflow += amount;
          int bucket = (txDate.day / 4).floor().clamp(0, 7);
          inflowBuckets[bucket] += amount;
        }
      }

      else if (type == 'borrow' || type == 'pool_expense') {
        poolBalance -= amount;
        if (tx['received_by'] == DemoData.userAId) userADebt += amount;
        if (tx['received_by'] == DemoData.userBId) userBDebt += amount;

        if (isSameMonth) {
          monthlyOutflow += amount;
          int bucket = (txDate.day / 4).floor().clamp(0, 7);
          outflowBuckets[bucket] += amount;
        }
      }
    }

    return FinanceSummary(
      poolBalance: poolBalance,
      inflow: monthlyInflow,
      outflow: monthlyOutflow,
      userADebt: userADebt < 0 ? 0 : userADebt,
      userBDebt: userBDebt < 0 ? 0 : userBDebt,
      inflowGraph: _normalize(inflowBuckets),
      outflowGraph: _normalize(outflowBuckets),
    );
  }

  static Map<String, List<Map<String, dynamic>>> groupTransactionsByMonth(List<Map<String, dynamic>> txs) {
    // 1. Filter for 'borrow' type only (Personal Screen requirement)
    final borrowTxs = txs.where((tx) => tx['type'] == 'borrow').toList();
    
    // 2. Sort Newest First
    borrowTxs.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var tx in borrowTxs) {
      final date = DateTime.parse(tx['date']);
      final monthKey = DateFormat('MMMM yyyy').format(date).toUpperCase();
      
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(tx);
    }
    
    return grouped;
  }

  static List<double> _normalize(List<double> data) {
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return List.filled(8, 0.1);
    return data.map((v) => v / maxVal).toList();
  }
}