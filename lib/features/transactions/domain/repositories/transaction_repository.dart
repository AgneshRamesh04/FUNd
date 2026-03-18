import '../entities/transaction_entity.dart';

/// Abstract repository for transaction operations
abstract class TransactionRepository {
  /// Fetch all transactions
  Future<List<TransactionEntity>> getTransactions();

  /// Fetch transactions for a specific trip
  Future<List<TransactionEntity>> getTransactionsByTrip(String tripId);

  /// Create a new transaction
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);

  /// Update an existing transaction
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId);

  /// Get borrow transactions for a user
  Future<List<TransactionEntity>> getUserBorrows(String userId);

  /// Get shared expenses for a user
  Future<List<TransactionEntity>> getUserSharedExpenses(String userId);

  /// Calculate pool balance
  Future<double> calculatePoolBalance();

  /// Calculate user debt
  Future<double> calculateUserDebt(String userId);

  /// Get monthly summary
  Future<MonthlySummaryEntity> getMonthlySummary(
    List<String> userIds,
    DateTime month,
  );

  /// Get trip summary
  Future<TripSummaryEntity> getTripSummary(
    String tripId,
    List<String> userIds,
  );

  /// Calculate settlement between two users
  Future<SettlementEntity> getSettlement(String userId1, String userId2);
}
