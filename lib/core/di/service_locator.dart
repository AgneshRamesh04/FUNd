import 'package:get_it/get_it.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/domain/usecases/home_usecases.dart';
import '../features/personal/domain/repositories/personal_repository.dart';
import '../features/personal/domain/usecases/personal_usecases.dart';
import '../features/shared/domain/repositories/shared_repository.dart';
import '../features/shared/domain/usecases/shared_usecases.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/transactions/domain/usecases/transaction_usecases.dart';
import '../features/transactions/data/data_sources/transaction_data_sources.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> setupServiceLocator() async {
  // ==================== Core Services ====================

  // ==================== Transaction Feature ====================
  // Data Sources
  getIt.registerSingleton<TransactionRemoteDataSource>(
    _MockTransactionRemoteDataSource(),
  );
  getIt.registerSingleton<TransactionLocalDataSource>(
    _MockTransactionLocalDataSource(),
  );

  // Repository
  getIt.registerSingleton<TransactionRepository>(
    TransactionRepositoryImpl(
      remoteDataSource: getIt<TransactionRemoteDataSource>(),
      localDataSource: getIt<TransactionLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton(GetTransactionsUseCase(getIt()));
  getIt.registerSingleton(CreateTransactionUseCase(getIt()));
  getIt.registerSingleton(UpdateTransactionUseCase(getIt()));
  getIt.registerSingleton(DeleteTransactionUseCase(getIt()));
  getIt.registerSingleton(GetUserBorrowsUseCase(getIt()));
  getIt.registerSingleton(GetUserSharedExpensesUseCase(getIt()));
  getIt.registerSingleton(GetPoolBalanceUseCase(getIt()));
  getIt.registerSingleton(GetUserDebtUseCase(getIt()));
  getIt.registerSingleton(GetMonthlySummaryUseCase(getIt()));
  getIt.registerSingleton(GetTripSummaryUseCase(getIt()));
  getIt.registerSingleton(GetSettlementUseCase(getIt()));

  // ==================== Auth Feature ====================
  // Repository (will be implemented)
  // getIt.registerSingleton<AuthRepository>(...);

  // Use Cases
  // getIt.registerSingleton(SignUpUseCase(getIt()));
  // getIt.registerSingleton(SignInUseCase(getIt()));
  // getIt.registerSingleton(SignOutUseCase(getIt()));
  // getIt.registerSingleton(GetCurrentUserUseCase(getIt()));
  // getIt.registerSingleton(IsAuthenticatedUseCase(getIt()));

  // ==================== Home Feature ====================
  // Repository (will be implemented)
  // getIt.registerSingleton<HomeRepository>(...);

  // Use Cases
  // getIt.registerSingleton(GetHomeStateUseCase(getIt()));
  // getIt.registerSingleton(GetPoolBalanceForHomeUseCase(getIt()));
  // getIt.registerSingleton(GetUserDebtsUseCase(getIt()));
  // getIt.registerSingleton(GetRecentTransactionsUseCase(getIt()));

  // ==================== Personal Feature ====================
  // Repository (will be implemented)
  // getIt.registerSingleton<PersonalRepository>(...);

  // Use Cases
  // getIt.registerSingleton(GetPersonalStateUseCase(getIt()));
  // getIt.registerSingleton(GetTotalBorrowedUseCase(getIt()));

  // ==================== Shared Feature ====================
  // Repository (will be implemented)
  // getIt.registerSingleton<SharedRepository>(...);

  // Use Cases
  // getIt.registerSingleton(GetSharedStateUseCase(getIt()));
  // getIt.registerSingleton(GetSettlementWithOtherUseCase(getIt()));
}

// ==================== Mock Implementations ====================
// These are temporary implementations. Replace with actual implementations
// that use Supabase and local database.

class _MockTransactionRemoteDataSource implements TransactionRemoteDataSource {
  @override
  Future<List<TransactionModel>> getTransactions() async {
    return [];
  }

  @override
  Future<List<TransactionModel>> getTransactionsByTrip(String tripId) async {
    return [];
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    return transaction;
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {}

  @override
  Stream<List<TransactionModel>> subscribeToTransactions() {
    return Stream.empty();
  }
}

class _MockTransactionLocalDataSource implements TransactionLocalDataSource {
  final List<TransactionModel> _cache = [];

  @override
  Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    _cache.clear();
    _cache.addAll(transactions);
  }

  @override
  Future<List<TransactionModel>> getCachedTransactions() async {
    return _cache;
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
  }
}
