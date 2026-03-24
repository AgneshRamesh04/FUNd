import '../services/supabase_service.dart';
import '../models/transaction_model.dart';
import '../models/trip_model.dart';
import '../models/pool_summary_model.dart';
import '../models/user_debts_model.dart';
import '../../features/home/domain/finance_service.dart';
import '../../features/home/domain/finance_summary.dart';

class TransactionRepository {
  final SupabaseService _supabaseService = SupabaseService();

  // In-memory caches for improved performance
  List<TransactionModel>? _transactionsCache;
  List<TripModel>? _tripsCache;
  Map<String, PoolSummaryModel>? _poolSummaryCache;
  Map<String, UserDebtsModel>? _userDebtsCache;

  // Singleton pattern
  static final TransactionRepository _instance = TransactionRepository._internal();
  factory TransactionRepository() => _instance;
  TransactionRepository._internal();

  // ===================== TRANSACTION OPERATIONS =====================

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      _transactionsCache = await _supabaseService.getAllTransactions();
      return _transactionsCache ?? [];
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByMonth(DateTime month) async {
    try {
      return await _supabaseService.getTransactionsByMonth(month);
    } catch (e) {
      print('Error fetching transactions by month: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    try {
      return await _supabaseService.getTransactionsByType(type);
    } catch (e) {
      print('Error fetching transactions by type: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getBorrowTransactions() async {
    return getTransactionsByType('borrow');
  }

  Future<List<TransactionModel>> getSharedExpenseTransactions() async {
    return getTransactionsByType('shared_expense');
  }

  Future<List<TransactionModel>> getDepositTransactions() async {
    return getTransactionsByType('deposit');
  }

  Future<List<TransactionModel>> getTransactionsByTrip(String tripId) async {
    try {
      return await _supabaseService.getTransactionsByTrip(tripId);
    } catch (e) {
      print('Error fetching transactions by trip: $e');
      return [];
    }
  }

  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await _supabaseService.createTransaction(transaction);
      _transactionsCache = null; // Invalidate cache
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _supabaseService.updateTransaction(transaction);
      _transactionsCache = null; // Invalidate cache
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _supabaseService.deleteTransaction(transactionId);
      _transactionsCache = null; // Invalidate cache
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  /// Optimized: Groups only 'borrow' transactions for Personal Screen
  Future<Map<String, List<Map<String, dynamic>>>> getPersonalGroups() async {
    final txs = await getBorrowTransactions();
    // Convert models back to maps for compatibility with FinanceService
    final txsMaps = txs.map((tx) => tx.toMap()).toList();
    return FinanceService.groupTransactionsByMonth(txsMaps);
  }

  // ===================== TRIP OPERATIONS =====================

  Future<List<TripModel>> getAllTrips() async {
    try {
      _tripsCache = await _supabaseService.getAllTrips();
      return _tripsCache ?? [];
    } catch (e) {
      print('Error fetching trips: $e');
      return [];
    }
  }

  Future<TripModel?> getTrip(String tripId) async {
    try {
      return await _supabaseService.getTrip(tripId);
    } catch (e) {
      print('Error fetching trip: $e');
      return null;
    }
  }

  Future<void> createTrip(TripModel trip) async {
    try {
      await _supabaseService.createTrip(trip);
      _tripsCache = null; // Invalidate cache
    } catch (e) {
      print('Error creating trip: $e');
      rethrow;
    }
  }

  Future<void> updateTrip(TripModel trip) async {
    try {
      await _supabaseService.updateTrip(trip);
      _tripsCache = null; // Invalidate cache
    } catch (e) {
      print('Error updating trip: $e');
      rethrow;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _supabaseService.deleteTrip(tripId);
      _tripsCache = null; // Invalidate cache
    } catch (e) {
      print('Error deleting trip: $e');
      rethrow;
    }
  }

  // ===================== VIEW TABLE OPERATIONS (Financial Data) =====================

  /// Fetch pool summary for a specific month (from pool_summary view)
  Future<PoolSummaryModel?> getPoolSummary(DateTime selectedMonth) async {
    try {
      return await _supabaseService.getPoolSummary(selectedMonth);
    } catch (e) {
      print('Error fetching pool summary: $e');
      return null;
    }
  }

  /// Fetch all user debts (from user_debts view)
  Future<List<UserDebtsModel>> getAllUserDebts() async {
    try {
      _userDebtsCache = {};
      final debts = await _supabaseService.getAllUserDebts();
      for (var debt in debts) {
        _userDebtsCache![debt.userId] = debt;
      }
      return debts;
    } catch (e) {
      print('Error fetching user debts: $e');
      return [];
    }
  }

  /// Fetch specific user debt (from user_debts view)
  Future<UserDebtsModel?> getUserDebts(String userId) async {
    try {
      // Check cache first
      if (_userDebtsCache != null && _userDebtsCache!.containsKey(userId)) {
        return _userDebtsCache![userId];
      }
      return await _supabaseService.getUserDebts(userId);
    } catch (e) {
      print('Error fetching user debt: $e');
      return null;
    }
  }

  // ===================== LEGACY COMPATIBILITY =====================

  /// Legacy method: Get home summary using Supabase views
  /// This now uses the backend-calculated pool_summary view instead of frontend calculations
  Future<FinanceSummary> getHomeSummary(DateTime selectedMonth) async {
    try {
      final poolSummary = await getPoolSummary(selectedMonth);
      
      // Get user debts
      final userDebts = await getAllUserDebts();
      
      // Map to FinanceSummary for UI compatibility
      return FinanceSummary(
        poolBalance: poolSummary?.poolBalance ?? 0.0,
        inflow: poolSummary?.monthlyInflow ?? 0.0,
        outflow: poolSummary?.monthlyOutflow ?? 0.0,
        userADebt: userDebts.isNotEmpty ? (userDebts[0].userDebts > 0 ? userDebts[0].userDebts : 0) : 0.0,
        userBDebt: userDebts.length > 1 ? (userDebts[1].userDebts > 0 ? userDebts[1].userDebts : 0) : 0.0,
        inflowGraph: [],
        outflowGraph: [],
      );
    } catch (e) {
      print('Error getting home summary: $e');
      return FinanceSummary(
        poolBalance: 0.0,
        inflow: 0.0,
        outflow: 0.0,
        userADebt: 0.0,
        userBDebt: 0.0,
        inflowGraph: [],
        outflowGraph: [],
      );
    }
  }

  // ===================== CACHE MANAGEMENT =====================

  void refresh() {
    _transactionsCache = null;
    _tripsCache = null;
    _poolSummaryCache = null;
    _userDebtsCache = null;
  }

  // ===================== REAL-TIME SUBSCRIPTIONS =====================

  void subscribeToTransactionChanges(Function(TransactionModel) onChanged) {
    _supabaseService.subscribeToTransactions(onChanged);
  }

  void subscribeToTripChanges(Function(TripModel) onChanged) {
    _supabaseService.subscribeToTrips(onChanged);
  }

  void subscribeToPoolBalanceChanges(Function() onChanged) {
    _supabaseService.subscribeToPoolBalance((_) {
      _poolSummaryCache = null; // Invalidate cache
      onChanged();
    });
  }

  void subscribeToUserDebtsChanges(Function() onChanged) {
    _supabaseService.subscribeToUserDebts((_) {
      _userDebtsCache = null; // Invalidate cache
      onChanged();
    });
  }
}
