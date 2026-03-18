import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/models.dart';
import '../services/supabase_service.dart';
import '../services/transaction_service.dart';

// Supabase Service Provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Current User Provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.getCurrentUser();
});

// All Transactions Provider
final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.fetchTransactions();
});

// Transactions for specific trip
final tripTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, tripId) async {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.fetchTransactions(tripId: tripId);
});

// User Borrows Provider
final userBorrowsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, userId) async {
  final transactions = await ref.watch(transactionsProvider.future);
  return TransactionService.getUserBorrows(userId, transactions);
});

// User Shared Expenses Provider
final userSharedExpensesProvider =
    FutureProvider.family<List<Transaction>, String>((ref, userId) async {
  final transactions = await ref.watch(transactionsProvider.future);
  return TransactionService.getUserSharedExpenses(userId, transactions);
});

// Pool Balance Provider
final poolBalanceProvider = FutureProvider<double>((ref) async {
  final transactions = await ref.watch(transactionsProvider.future);
  return TransactionService.calculatePoolBalance(transactions);
});

// User Debt Provider
final userDebtProvider =
    FutureProvider.family<double, String>((ref, userId) async {
  final transactions = await ref.watch(transactionsProvider.future);
  return TransactionService.calculateUserDebt(userId, transactions);
});

// Monthly Summary Provider
final monthlySummaryProvider = FutureProvider.family<MonthlySummary, 
    ({List<String> userIds, DateTime month})>((ref, params) async {
  final transactions = await ref.watch(transactionsProvider.future);
  return TransactionService.calculateMonthlySummary(
    transactions,
    params.userIds,
    params.month,
  );
});

// All Trips Provider
final tripsProvider = FutureProvider<List<Trip>>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.fetchTrips();
});

// Trip Summary Provider
final tripSummaryProvider =
    FutureProvider.family<TripSummary, ({Trip trip, List<String> userIds})>(
  (ref, params) async {
    final transactions = await ref.watch(transactionsProvider.future);
    return TransactionService.getTripSummary(
      params.trip,
      transactions,
      params.userIds,
    );
  },
);

// Leave Tracking Provider
final leaveTrackingProvider =
    FutureProvider.family<List<LeaveTracking>, String>((ref, userId) async {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.fetchLeaveTracking(userId);
});

// Settlement between two users
final settlementProvider = FutureProvider.family<double, 
    ({String userId1, String userId2})>((ref, params) async {
  final transactions = await ref.watch(transactionsProvider.future);
  return TransactionService.getSettlementAmount(
    params.userId1,
    params.userId2,
    transactions,
  );
});

// Users Provider
final usersProvider = FutureProvider<List<User>>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.fetchUsers();
});
