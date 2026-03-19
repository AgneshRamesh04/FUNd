import '../domain/home_repository.dart';
import '../domain/finance_summary.dart';
import '../domain/finance_service.dart';
import '../../../core/constants/demo_data.dart';

class HomeRepositoryImpl {
  // Mock cache to avoid recalculating on every UI rebuild
  FinanceSummary? _cachedSummary;
  DateTime? _cachedMonth;

  Future<FinanceSummary> getSummary(DateTime selectedMonth) async {
    // Check if we already have the data calculated for this month
    if (_cachedSummary != null && _cachedMonth == selectedMonth) {
      return _cachedSummary!;
    }

    // PLACEHOLDER: In real app:
    // final response = await supabase.from('transactions').select();
    final data = DemoData.mockTransactions;

    _cachedSummary = FinanceService.calculate(
      allTransactions: data,
      selectedDate: selectedMonth,
    );
    _cachedMonth = selectedMonth;

    return _cachedSummary!;
  }
}