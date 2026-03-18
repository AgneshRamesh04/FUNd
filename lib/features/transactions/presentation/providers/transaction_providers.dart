import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';
import '../domain/entities/transaction_entity.dart';
import '../domain/usecases/transaction_usecases.dart';

// Use Case Providers
final getTransactionsUseCaseProvider = Provider(
  (_) => getIt<GetTransactionsUseCase>(),
);

final createTransactionUseCaseProvider = Provider(
  (_) => getIt<CreateTransactionUseCase>(),
);

final updateTransactionUseCaseProvider = Provider(
  (_) => getIt<UpdateTransactionUseCase>(),
);

final deleteTransactionUseCaseProvider = Provider(
  (_) => getIt<DeleteTransactionUseCase>(),
);

final getUserBorrowsUseCaseProvider = Provider(
  (_) => getIt<GetUserBorrowsUseCase>(),
);

final getUserSharedExpensesUseCaseProvider = Provider(
  (_) => getIt<GetUserSharedExpensesUseCase>(),
);

final getPoolBalanceUseCaseProvider = Provider(
  (_) => getIt<GetPoolBalanceUseCase>(),
);

final getUserDebtUseCaseProvider = Provider(
  (_) => getIt<GetUserDebtUseCase>(),
);

// Data Providers
final transactionsProvider =
    FutureProvider<List<TransactionEntity>>((ref) async {
  final useCase = ref.watch(getTransactionsUseCaseProvider);
  return useCase();
});

final userBorrowsProvider =
    FutureProvider.family<List<TransactionEntity>, String>(
  (ref, userId) async {
    final transactions = await ref.watch(transactionsProvider.future);
    return transactions
        .where((t) =>
            t.type == TransactionType.borrow && t.receivedBy == userId)
        .toList();
  },
);

final userSharedExpensesProvider =
    FutureProvider.family<List<TransactionEntity>, String>(
  (ref, userId) async {
    final transactions = await ref.watch(transactionsProvider.future);
    return transactions
        .where((t) =>
            t.type == TransactionType.sharedExpense &&
            (t.paidBy == userId || t.receivedBy.contains(userId)))
        .toList();
  },
);

final poolBalanceProvider = FutureProvider<double>((ref) async {
  final useCase = ref.watch(getPoolBalanceUseCaseProvider);
  return useCase();
});

final userDebtProvider =
    FutureProvider.family<double, String>((ref, userId) async {
  final useCase = ref.watch(getUserDebtUseCaseProvider);
  return useCase(userId);
});

final monthlySummaryProvider = FutureProvider.family<MonthlySummaryEntity,
    ({List<String> userIds, DateTime month})>((ref, params) async {
  final useCase = getIt<GetMonthlySummaryUseCase>();
  return useCase(params.userIds, params.month);
});

final tripSummaryProvider =
    FutureProvider.family<TripSummaryEntity, ({String tripId, List<String> userIds})>(
  (ref, params) async {
    final useCase = getIt<GetTripSummaryUseCase>();
    return useCase(params.tripId, params.userIds);
  },
);

final settlementProvider = FutureProvider.family<SettlementEntity,
    ({String userId1, String userId2})>((ref, params) async {
  final useCase = getIt<GetSettlementUseCase>();
  return useCase(params.userId1, params.userId2);
});
