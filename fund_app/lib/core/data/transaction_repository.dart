import '../constants/demo_data.dart';
import '../../features/home/domain/finance_service.dart';
import '../../features/home/domain/finance_summary.dart';

class TransactionRepository {
  // Simple in-memory cache
  List<Map<String, dynamic>>? _allTransactionsCache;
  List<Map<String, dynamic>>? _allTripsCache;

  // Singleton pattern so Home and Personal share the same data instance
  static final TransactionRepository _instance = TransactionRepository._internal();
  factory TransactionRepository() => _instance;
  TransactionRepository._internal();

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    if (_allTransactionsCache != null) {
      return _allTransactionsCache!;
    }

    // PLACEHOLDER: actual Supabase fetch would go here
    // final response = await supabase.from('transactions').select();
    print("--- FETCHING FROM SOURCE ---");
    _allTransactionsCache = List.from(DemoData.mockTransactions);
    
    return _allTransactionsCache!;
  }

  /// Optimized: Calculates the Home Summary using the cache
  Future<FinanceSummary> getHomeSummary(DateTime selectedMonth) async {
    final txs = await getAllTransactions();
    return FinanceService.calculate(
      allTransactions: txs,
      selectedDate: selectedMonth,
    );
  }

  /// Optimized: Groups only 'borrow' transactions for Personal Screen
  Future<Map<String, List<Map<String, dynamic>>>> getPersonalGroups() async {
    final txs = await getAllTransactions();
    // Re-using the logic we wrote for grouping
    return FinanceService.groupTransactionsByMonth(txs);
  }

  /// Fetches trips from mock data or Supabase
  Future<List<Map<String, dynamic>>> getAllTrips() async {
    if (_allTripsCache != null) return _allTripsCache!;

    // In the future: await supabase.from('trips').select();
    _allTripsCache = List.from(DemoData.mockTrips);
    return _allTripsCache!;
  }

  void refresh() {
    _allTransactionsCache = null;
    _allTripsCache = null; // Clear both on refresh
  }
}