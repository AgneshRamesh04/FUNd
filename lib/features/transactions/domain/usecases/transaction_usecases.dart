import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use case to fetch all transactions
class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call() async {
    return repository.getTransactions();
  }
}

/// Use case to create a transaction
class CreateTransactionUseCase {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<TransactionEntity> call(TransactionEntity transaction) async {
    return repository.createTransaction(transaction);
  }
}

/// Use case to update a transaction
class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<TransactionEntity> call(TransactionEntity transaction) async {
    return repository.updateTransaction(transaction);
  }
}

/// Use case to delete a transaction
class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<void> call(String transactionId) async {
    return repository.deleteTransaction(transactionId);
  }
}

/// Use case to get user borrows
class GetUserBorrowsUseCase {
  final TransactionRepository repository;

  GetUserBorrowsUseCase(this.repository);

  Future<List<TransactionEntity>> call(String userId) async {
    return repository.getUserBorrows(userId);
  }
}

/// Use case to get shared expenses
class GetUserSharedExpensesUseCase {
  final TransactionRepository repository;

  GetUserSharedExpensesUseCase(this.repository);

  Future<List<TransactionEntity>> call(String userId) async {
    return repository.getUserSharedExpenses(userId);
  }
}

/// Use case to calculate pool balance
class GetPoolBalanceUseCase {
  final TransactionRepository repository;

  GetPoolBalanceUseCase(this.repository);

  Future<double> call() async {
    return repository.calculatePoolBalance();
  }
}

/// Use case to calculate user debt
class GetUserDebtUseCase {
  final TransactionRepository repository;

  GetUserDebtUseCase(this.repository);

  Future<double> call(String userId) async {
    return repository.calculateUserDebt(userId);
  }
}

/// Use case to get monthly summary
class GetMonthlySummaryUseCase {
  final TransactionRepository repository;

  GetMonthlySummaryUseCase(this.repository);

  Future<MonthlySummaryEntity> call(
    List<String> userIds,
    DateTime month,
  ) async {
    return repository.getMonthlySummary(userIds, month);
  }
}

/// Use case to get trip summary
class GetTripSummaryUseCase {
  final TransactionRepository repository;

  GetTripSummaryUseCase(this.repository);

  Future<TripSummaryEntity> call(
    String tripId,
    List<String> userIds,
  ) async {
    return repository.getTripSummary(tripId, userIds);
  }
}

/// Use case to get settlement
class GetSettlementUseCase {
  final TransactionRepository repository;

  GetSettlementUseCase(this.repository);

  Future<SettlementEntity> call(String userId1, String userId2) async {
    return repository.getSettlement(userId1, userId2);
  }
}
