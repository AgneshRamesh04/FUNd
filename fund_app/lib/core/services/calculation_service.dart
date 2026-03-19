import 'package:fund_app/core/models/transaction_model.dart';

class CalculationService {
  /// Calculate pool balance from transactions
  /// Pool balance = Total deposits - Total borrows - Total pool expenses
  double calculatePoolBalance(List<Transaction> transactions) {
    double poolBalance = 0;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.deposit:
          // User deposited to pool
          poolBalance += transaction.amount;
          break;
        case TransactionType.borrow:
          // User borrowed from pool
          poolBalance -= transaction.amount;
          break;
        case TransactionType.poolExpense:
          // Pool paid for something
          poolBalance -= transaction.amount;
          break;
        case TransactionType.sharedExpense:
          // Shared expense doesn't directly affect pool
          break;
      }
    }

    return poolBalance;
  }

  /// Calculate user debt to pool
  /// User debt = Total borrowed - Total deposited + share of shared expenses
  double calculateUserDebt(
    List<Transaction> transactions,
    String userId,
  ) {
    double debt = 0;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.borrow:
          if (transaction.receivedBy == userId) {
            debt += transaction.amount;
          }
          break;
        case TransactionType.deposit:
          if (transaction.paidBy == userId) {
            debt -= transaction.amount;
          }
          break;
        case TransactionType.sharedExpense:
          if (transaction.paidBy == userId) {
            // User paid, so they are owed
            final split = _calculateSplit(transaction, userId);
            debt -= split;
          } else {
            // User is in split, so they owe
            final split = _calculateSplit(transaction, userId);
            debt += split;
          }
          break;
        case TransactionType.poolExpense:
          // Doesn't directly affect user debt
          break;
      }
    }

    return debt;
  }

  /// Calculate monthly inflow (deposits + shared expense payments)
  double calculateMonthlyInflow(
    List<Transaction> transactions,
    String userId,
    int month,
    int year,
  ) {
    double inflow = 0;

    for (final transaction in transactions) {
      if (transaction.date.month == month && transaction.date.year == year) {
        switch (transaction.type) {
          case TransactionType.deposit:
            if (transaction.paidBy == userId) {
              inflow += transaction.amount;
            }
            break;
          case TransactionType.sharedExpense:
            if (transaction.paidBy == userId) {
              inflow += transaction.amount;
            }
            break;
          default:
            break;
        }
      }
    }

    return inflow;
  }

  /// Calculate monthly outflow (borrows + share of shared expenses paid by others)
  double calculateMonthlyOutflow(
    List<Transaction> transactions,
    String userId,
    int month,
    int year,
  ) {
    double outflow = 0;

    for (final transaction in transactions) {
      if (transaction.date.month == month && transaction.date.year == year) {
        switch (transaction.type) {
          case TransactionType.borrow:
            if (transaction.receivedBy == userId) {
              outflow += transaction.amount;
            }
            break;
          case TransactionType.sharedExpense:
            if (transaction.paidBy != userId) {
              final split = _calculateSplit(transaction, userId);
              outflow += split;
            }
            break;
          default:
            break;
        }
      }
    }

    return outflow;
  }

  /// Helper: Calculate split amount for a transaction
  double _calculateSplit(Transaction transaction, String userId) {
    if (transaction.splitType == SplitType.equal) {
      // Equal split between 2 users
      return transaction.amount / 2;
    } else if (transaction.splitType == SplitType.custom && transaction.splitData != null) {
      // Custom split
      final userSplit = transaction.splitData![userId];
      return userSplit is double ? userSplit : (userSplit as num).toDouble();
    }
    return 0;
  }

  /// Get summary for specific month
  Map<String, double> getMonthlysSummary(
    List<Transaction> transactions,
    String userId,
    int month,
    int year,
  ) {
    return {
      'inflow': calculateMonthlyInflow(transactions, userId, month, year),
      'outflow': calculateMonthlyOutflow(transactions, userId, month, year),
    };
  }
}
