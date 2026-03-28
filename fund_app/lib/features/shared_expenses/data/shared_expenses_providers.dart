import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../home/data/home_providers.dart';
import 'shared_expenses_models.dart';
import 'shared_expenses_repository.dart';

final sharedExpensesRepositoryProvider =
    Provider<SharedExpensesRepository>((ref) {
  return SharedExpensesRepository(ref.watch(supabaseClientProvider));
});

// ── Pool month expense ────────────────────────────────────────────────────────

final poolMonthExpenseProvider =
    FutureProvider.family<Map<String, double>, DateTime>((ref, month) async {
  return ref
      .watch(sharedExpensesRepositoryProvider)
      .fetchPoolMonthExpense(month);
});

// ── Pool summary total expense ────────────────────────────────────────────────

final poolSummaryTotalProvider =
    FutureProvider.family<double, DateTime>((ref, month) async {
  return ref
      .watch(sharedExpensesRepositoryProvider)
      .fetchPoolSummaryTotal(month);
});

// ── Active trip ───────────────────────────────────────────────────────────────

final activeTripProvider = FutureProvider<TripSummary?>((ref) async {
  return ref
      .watch(sharedExpensesRepositoryProvider)
      .fetchActiveTripSummary();
});

// ── All trips ─────────────────────────────────────────────────────────────────

final allTripsProvider = FutureProvider<List<TripSummary>>((ref) async {
  return ref
      .watch(sharedExpensesRepositoryProvider)
      .fetchAllTrips();
});

// ── Paginated shared transactions ─────────────────────────────────────────────

class SharedTransactionsState {
  final List<SharedTransaction> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const SharedTransactionsState({
    this.transactions = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  SharedTransactionsState copyWith({
    List<SharedTransaction>? transactions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return SharedTransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SharedTransactionsNotifier
    extends StateNotifier<SharedTransactionsState> {
  SharedTransactionsNotifier(this._repo)
      : super(const SharedTransactionsState()) {
    _loadFirst();
  }

  final SharedExpensesRepository _repo;

  Future<void> _loadFirst() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repo.fetchSharedTransactions(offset: 0);
      state = SharedTransactionsState(
        transactions: data,
        isLoading: false,
        hasMore: data.length == SharedExpensesRepository.pageSize,
      );
    } catch (e) {
      final friendlyError = _getFriendlyErrorMessage(e);
      state = state.copyWith(isLoading: false, error: friendlyError);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final data = await _repo.fetchSharedTransactions(
        offset: state.transactions.length,
      );
      state = state.copyWith(
        transactions: [...state.transactions, ...data],
        isLoadingMore: false,
        hasMore: data.length == SharedExpensesRepository.pageSize,
      );
    } catch (e) {
      final friendlyError = _getFriendlyErrorMessage(e);
      state = state.copyWith(isLoadingMore: false, error: friendlyError);
    }
  }

  String _getFriendlyErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Failed to load transactions. Please try again.';
  }
}

final sharedTransactionsProvider = StateNotifierProvider<
    SharedTransactionsNotifier, SharedTransactionsState>((ref) {
  return SharedTransactionsNotifier(
      ref.watch(sharedExpensesRepositoryProvider));
});

// ── User names ────────────────────────────────────────────────────────────────

final sharedUserNamesProvider =
    FutureProvider<Map<String, String>>((ref) async {
  return ref
      .watch(sharedExpensesRepositoryProvider)
      .fetchUserNames();
});
