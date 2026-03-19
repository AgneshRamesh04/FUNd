import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fund_app/core/models/transaction_model.dart';
import 'package:fund_app/core/repositories/transaction_repository.dart';
import 'package:fund_app/core/services/calculation_service.dart';
import 'package:fund_app/core/services/transaction_service.dart';
import 'package:fund_app/core/services/supabase_service.dart';

class HomeState {
  final List<Transaction> transactions;
  final double poolBalance;
  final Map<String, double> userDebts;
  final Map<String, dynamic> monthlySummary;
  final bool isLoading;
  final String? error;

  HomeState({
    required this.transactions,
    required this.poolBalance,
    required this.userDebts,
    required this.monthlySummary,
    required this.isLoading,
    this.error,
  });

  HomeState copyWith({
    List<Transaction>? transactions,
    double? poolBalance,
    Map<String, double>? userDebts,
    Map<String, dynamic>? monthlySummary,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      transactions: transactions ?? this.transactions,
      poolBalance: poolBalance ?? this.poolBalance,
      userDebts: userDebts ?? this.userDebts,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final TransactionRepository _transactionRepository;
  final CalculationService _calculationService;

  HomeNotifier(
    this._transactionRepository,
    this._calculationService,
  ) : super(
    HomeState(
      transactions: [],
      poolBalance: 0,
      userDebts: {},
      monthlySummary: {},
      isLoading: true,
    ),
  ) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _transactionRepository.getTransactions();
      final poolBalance = _calculationService.calculatePoolBalance(transactions);
      
      // TODO: Get actual user IDs from auth service
      final userDebts = {
        'user1': _calculationService.calculateUserDebt(transactions, 'user1'),
        'user2': _calculationService.calculateUserDebt(transactions, 'user2'),
      };

      final now = DateTime.now();
      final monthlySummary = {
        'user1': _calculationService.getMonthlysSummary(
          transactions,
          'user1',
          now.month,
          now.year,
        ),
        'user2': _calculationService.getMonthlysSummary(
          transactions,
          'user2',
          now.month,
          now.year,
        ),
      };

      state = state.copyWith(
        transactions: transactions,
        poolBalance: poolBalance,
        userDebts: userDebts,
        monthlySummary: monthlySummary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final transactionRepository = ref.watch(_transactionRepositoryProvider);
  final calculationService = ref.watch(_calculationServiceProvider);
  return HomeNotifier(transactionRepository, calculationService);
});

// Internal providers to avoid circular imports
final _transactionRepositoryProvider = Provider((ref) {
  final transactionService = ref.watch(_transactionServiceProvider);
  return TransactionRepository(transactionService);
});

final _calculationServiceProvider = Provider((ref) {
  return CalculationService();
});

final _transactionServiceProvider = Provider((ref) {
  final supabaseService = ref.watch(_supabaseServiceProvider);
  return TransactionService(supabaseService);
});

final _supabaseServiceProvider = Provider((ref) {
  return SupabaseService();
});
