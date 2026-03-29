import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/home_providers.dart';
import 'personal_models.dart';
import 'personal_repository.dart';

final personalRepositoryProvider = Provider<PersonalRepository>((ref) {
  return PersonalRepository(ref.watch(supabaseClientProvider));
});

// ── Pagination state ──────────────────────────────────────────────────────────

class PersonalTransactionsState {
  final List<PersonalTransaction> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const PersonalTransactionsState({
    this.transactions = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  PersonalTransactionsState copyWith({
    List<PersonalTransaction>? transactions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return PersonalTransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PersonalTransactionsNotifier
    extends StateNotifier<PersonalTransactionsState> {
  PersonalTransactionsNotifier(this._repo, this._monthKey)
      : super(const PersonalTransactionsState()) {
    _loadFirst();
  }

  final PersonalRepository _repo;
  final String _monthKey;

  Future<void> _loadFirst() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repo.fetchPersonalTransactions(
        monthKey: _monthKey,
        offset: 0,
      );
      state = PersonalTransactionsState(
        transactions: data,
        isLoading: false,
        hasMore: data.length == PersonalRepository.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final data = await _repo.fetchPersonalTransactions(
        monthKey: _monthKey,
        offset: state.transactions.length,
      );
      state = state.copyWith(
        transactions: [...state.transactions, ...data],
        isLoadingMore: false,
        hasMore: data.length == PersonalRepository.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

/// Family provider keyed by month (YYYY-MM format) for caching per month
final personalTransactionsProvider = StateNotifierProvider.family<
    PersonalTransactionsNotifier, PersonalTransactionsState, String>((ref, monthKey) {
  return PersonalTransactionsNotifier(
    ref.watch(personalRepositoryProvider),
    monthKey,
  );
});

final personalUserNamesProvider =
    FutureProvider<Map<String, String>>((ref) async {
  return ref.watch(personalRepositoryProvider).fetchUserNames();
});
