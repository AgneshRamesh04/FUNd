import 'finance_summary.dart';

abstract class HomeRepository {
  Future<FinanceSummary> getMonthlySummary(DateTime month);
}