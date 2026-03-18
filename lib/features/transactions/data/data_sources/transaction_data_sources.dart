import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

/// Abstract data source for remote transaction operations
abstract class TransactionRemoteDataSource {
  /// Fetch all transactions
  Future<List<TransactionModel>> getTransactions();

  /// Fetch transactions for a trip
  Future<List<TransactionModel>> getTransactionsByTrip(String tripId);

  /// Create a transaction
  Future<TransactionModel> createTransaction(TransactionModel transaction);

  /// Update a transaction
  Future<TransactionModel> updateTransaction(TransactionModel transaction);

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId);

  /// Subscribe to real-time updates
  Stream<List<TransactionModel>> subscribeToTransactions();
}

/// Abstract data source for local transaction operations
abstract class TransactionLocalDataSource {
  /// Save transactions locally
  Future<void> cacheTransactions(List<TransactionModel> transactions);

  /// Get cached transactions
  Future<List<TransactionModel>> getCachedTransactions();

  /// Clear cached transactions
  Future<void> clearCache();
}
