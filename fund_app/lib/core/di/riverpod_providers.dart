import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fund_app/core/services/supabase_service.dart';
import 'package:fund_app/core/services/auth_service.dart';
import 'package:fund_app/core/services/transaction_service.dart';
import 'package:fund_app/core/services/calculation_service.dart';
import 'package:fund_app/core/repositories/transaction_repository.dart';
import 'package:fund_app/core/repositories/user_repository.dart';
import 'package:fund_app/core/repositories/trip_repository.dart';
import 'package:fund_app/core/models/transaction_model.dart';

// ============================================================================
// CORE SERVICES - These should be singletons
// ============================================================================

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthService(supabaseService);
});

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return TransactionService(supabaseService);
});

final calculationServiceProvider = Provider<CalculationService>((ref) {
  return CalculationService();
});

// ============================================================================
// REPOSITORIES - Data access layer
// ============================================================================

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final transactionService = ref.watch(transactionServiceProvider);
  return TransactionRepository(transactionService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return UserRepository(supabaseService);
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return TripRepository(supabaseService);
});

// ============================================================================
// CURRENT USER - Get the logged-in user ID
// ============================================================================

final currentUserIdProvider = Provider<String?>((ref) {
  return SupabaseService().userId;
});

// ============================================================================
// TRANSACTIONS - Get all transactions as Future (one-time fetch)
// ============================================================================

final allTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactions(limit: 1000);
});

// ============================================================================
// TRANSACTIONS - Real-time stream of transactions
// ============================================================================

final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactions();
});

// ============================================================================
// BORROW TRANSACTIONS - Filtered borrow transactions
// ============================================================================

final borrowTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactions = await ref.watch(allTransactionsProvider.future);
  return transactions.where((t) => t.type == TransactionType.borrow).toList();
});

// ============================================================================
// SHARED EXPENSES - Filtered shared expense transactions
// ============================================================================

final sharedExpensesProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactions = await ref.watch(allTransactionsProvider.future);
  return transactions
      .where((t) => t.type == TransactionType.sharedExpense)
      .toList();
});

// ============================================================================
// POOL BALANCE - Calculated pool balance
// ============================================================================

final poolBalanceProvider = FutureProvider<double>((ref) async {
  final transactions = await ref.watch(allTransactionsProvider.future);
  final calcService = ref.watch(calculationServiceProvider);
  return calcService.calculatePoolBalance(transactions);
});

// ============================================================================
// USER DEBTS - Calculated debt for both users
// ============================================================================

final userDebtsProvider = FutureProvider<Map<String, double>>((ref) async {
  final transactions = await ref.watch(allTransactionsProvider.future);
  final calcService = ref.watch(calculationServiceProvider);

  return {
    'user1': calcService.calculateUserDebt(transactions, 'user1'),
    'user2': calcService.calculateUserDebt(transactions, 'user2'),
  };
});

// ============================================================================
// MONTHLY SUMMARY - Summary for current month
// ============================================================================

final currentMonthlySummaryProvider =
    FutureProvider<Map<String, Map<String, double>>>((ref) async {
  final transactions = await ref.watch(allTransactionsProvider.future);
  final calcService = ref.watch(calculationServiceProvider);
  final now = DateTime.now();

  return {
    'user1': calcService.getMonthlysSummary(
      transactions,
      'user1',
      now.month,
      now.year,
    ),
    'user2': calcService.getMonthlysSummary(
      transactions,
      'user2',
      now.month,
      now.year,
    ),
  };
});

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

// In a screen:
// class MyScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Get all transactions (one-time fetch)
//     final transactions = ref.watch(allTransactionsProvider);
//     
//     // Get real-time transactions stream
//     final transactionsStream = ref.watch(transactionsStreamProvider);
//     
//     // Get pool balance
//     final poolBalance = ref.watch(poolBalanceProvider);
//     
//     // Get user debts
//     final debts = ref.watch(userDebtsProvider);
//     
//     // Refresh data
//     ref.refresh(allTransactionsProvider);
//     
//     return Scaffold(...);
//   }
// }

// ============================================================================
// ADDITIONAL PROVIDER PATTERNS
// ============================================================================

// Provider with parameter (e.g., get specific user's transactions)
// final userTransactionsProvider = FutureProvider.family<List<Transaction>, String>(
//     (ref, userId) async {
//   final repo = ref.watch(transactionRepositoryProvider);
//   final transactions = await repo.getTransactions();
//   return transactions.where((t) => t.paidBy == userId).toList();
// });

// Usage: ref.watch(userTransactionsProvider('user1'))

// ============================================================================
// FAMILY PROVIDERS - For generic queries
// ============================================================================

final monthlyTransactionsProvider = FutureProvider.family<
    Map<String, Map<String, double>>,
    (int month, int year)>((ref, params) async {
  final transactions = await ref.watch(allTransactionsProvider.future);
  final calcService = ref.watch(calculationServiceProvider);

  return {
    'user1': calcService.getMonthlysSummary(
      transactions,
      'user1',
      params.$1,
      params.$2,
    ),
    'user2': calcService.getMonthlysSummary(
      transactions,
      'user2',
      params.$1,
      params.$2,
    ),
  };
});

// Usage: ref.watch(monthlyTransactionsProvider((3, 2026)))
