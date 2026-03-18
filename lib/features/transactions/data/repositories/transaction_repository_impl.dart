import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../data_sources/transaction_data_sources.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction_entity.dart' as entities;

/// Concrete implementation of TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    try {
      final remoteTransactions = await remoteDataSource.getTransactions();
      await localDataSource.cacheTransactions(remoteTransactions);
      return remoteTransactions.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Fallback to local cache
      final cachedTransactions = await localDataSource.getCachedTransactions();
      return cachedTransactions.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByTrip(String tripId) async {
    try {
      final transactions = await remoteDataSource.getTransactionsByTrip(tripId);
      return transactions.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionEntity> createTransaction(
    TransactionEntity transaction,
  ) async {
    final model = TransactionModel.fromEntity(transaction);
    final created = await remoteDataSource.createTransaction(model);
    return created.toEntity();
  }

  @override
  Future<TransactionEntity> updateTransaction(
    TransactionEntity transaction,
  ) async {
    final model = TransactionModel.fromEntity(transaction);
    final updated = await remoteDataSource.updateTransaction(model);
    return updated.toEntity();
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await remoteDataSource.deleteTransaction(transactionId);
  }

  @override
  Future<List<TransactionEntity>> getUserBorrows(String userId) async {
    final transactions = await getTransactions();
    return transactions
        .where((t) =>
            t.type == TransactionType.borrow && t.receivedBy == userId)
        .toList();
  }

  @override
  Future<List<TransactionEntity>> getUserSharedExpenses(
    String userId,
  ) async {
    final transactions = await getTransactions();
    return transactions
        .where((t) =>
            t.type == TransactionType.sharedExpense &&
            (t.paidBy == userId || t.receivedBy.contains(userId)))
        .toList();
  }

  @override
  Future<double> calculatePoolBalance() async {
    final transactions = await getTransactions();
    return _calculatePoolBalance(transactions);
  }

  @override
  Future<double> calculateUserDebt(String userId) async {
    final transactions = await getTransactions();
    return _calculateUserDebt(userId, transactions);
  }

  @override
  Future<entities.MonthlySummaryEntity> getMonthlySummary(
    List<String> userIds,
    DateTime month,
  ) async {
    final transactions = await getTransactions();
    final monthTransactions = transactions.where((t) {
      return t.date.year == month.year && t.date.month == month.month;
    }).toList();

    double inflow = 0;
    double outflow = 0;

    for (final transaction in monthTransactions) {
      switch (transaction.type) {
        case TransactionType.deposit:
          inflow += transaction.amount;
          break;
        case TransactionType.borrow:
        case TransactionType.sharedExpense:
        case TransactionType.poolExpense:
          outflow += transaction.amount;
          break;
      }
    }

    final poolBalance = _calculatePoolBalance(transactions);
    final userDebts = {
      for (final userId in userIds) userId: _calculateUserDebt(userId, transactions)
    };

    return entities.MonthlySummaryEntity(
      poolBalance: poolBalance,
      inflow: inflow,
      outflow: outflow,
      userDebts: userDebts,
    );
  }

  @override
  Future<entities.TripSummaryEntity> getTripSummary(
    String tripId,
    List<String> userIds,
  ) async {
    final transactions = await getTransactionsByTrip(tripId);

    double totalCost = 0;
    final contributions = {for (final userId in userIds) userId: 0.0};

    for (final transaction in transactions) {
      totalCost += transaction.amount;

      if (transaction.type == TransactionType.sharedExpense) {
        if (transaction.splitType == SplitType.equal) {
          final share = transaction.amount / 2;
          for (final userId in userIds) {
            if (userId != transaction.paidBy) {
              contributions[userId] = (contributions[userId] ?? 0) + share;
            }
          }
        } else if (transaction.splitType == SplitType.custom &&
            transaction.splitData != null) {
          for (final userId in userIds) {
            final share = transaction.splitData![userId] as double? ?? 0;
            if (share > 0) {
              contributions[userId] = (contributions[userId] ?? 0) + share;
            }
          }
        }
      } else if (transaction.type == TransactionType.borrow) {
        contributions[transaction.receivedBy] =
            (contributions[transaction.receivedBy] ?? 0) + transaction.amount;
      }
    }

    return entities.TripSummaryEntity(
      tripId: tripId,
      tripName: 'Trip',
      expenses: transactions,
      contributions: contributions,
      totalCost: totalCost,
    );
  }

  @override
  Future<entities.SettlementEntity> getSettlement(
    String userId1,
    String userId2,
  ) async {
    final transactions = await getTransactions();
    double amount = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.sharedExpense) {
        if (transaction.paidBy == userId1 &&
            transaction.receivedBy.contains(userId2)) {
          if (transaction.splitType == SplitType.equal) {
            amount += transaction.amount / 2;
          } else if (transaction.splitType == SplitType.custom &&
              transaction.splitData != null) {
            amount += transaction.splitData![userId2] as double? ?? 0;
          }
        } else if (transaction.paidBy == userId2 &&
            transaction.receivedBy.contains(userId1)) {
          if (transaction.splitType == SplitType.equal) {
            amount -= transaction.amount / 2;
          } else if (transaction.splitType == SplitType.custom &&
              transaction.splitData != null) {
            amount -= transaction.splitData![userId1] as double? ?? 0;
          }
        }
      }
    }

    return entities.SettlementEntity(
      userId1: userId1,
      userId2: userId2,
      amount: amount,
    );
  }

  // Private helper methods
  double _calculatePoolBalance(List<TransactionEntity> transactions) {
    double balance = 0;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.deposit:
          if (transaction.receivedBy == 'pool') {
            balance += transaction.amount;
          }
          break;
        case TransactionType.borrow:
          if (transaction.paidBy == 'pool') {
            balance -= transaction.amount;
          }
          break;
        case TransactionType.sharedExpense:
          if (transaction.paidBy == 'pool') {
            balance -= transaction.amount;
          }
          break;
        case TransactionType.poolExpense:
          balance -= transaction.amount;
          break;
      }
    }

    return balance;
  }

  double _calculateUserDebt(
    String userId,
    List<TransactionEntity> transactions,
  ) {
    double debt = 0;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.borrow:
          if (transaction.receivedBy == userId && transaction.paidBy == 'pool') {
            debt += transaction.amount;
          }
          break;
        case TransactionType.deposit:
          if (transaction.paidBy == userId && transaction.receivedBy == 'pool') {
            debt -= transaction.amount;
          }
          break;
        case TransactionType.sharedExpense:
          if (transaction.splitType == SplitType.equal) {
            final halfAmount = transaction.amount / 2;
            if (transaction.paidBy == userId) {
              debt -= halfAmount;
            } else {
              debt += halfAmount;
            }
          } else if (transaction.splitType == SplitType.custom &&
              transaction.splitData != null) {
            final userShare = transaction.splitData![userId] as double? ?? 0;
            if (transaction.paidBy == userId) {
              debt -= (transaction.amount - userShare);
            } else {
              debt += userShare;
            }
          }
          break;
        case TransactionType.poolExpense:
          break;
      }
    }

    return debt;
  }
}
