import '../database/models.dart';

/// Service layer for all transaction calculations
/// All financial logic must be handled here, not in UI
class TransactionService {
  /// Calculate pool balance from transactions
  /// Pool balance = deposits - borrows - shared expenses (pool's share) - pool expenses
  static double calculatePoolBalance(List<Transaction> transactions) {
    double balance = 0;
    
    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.deposit:
          // User depositing money to pool
          if (transaction.receivedBy == 'pool') {
            balance += transaction.amount;
          }
          break;
        case TransactionType.borrow:
          // User borrowing from pool
          if (transaction.paidBy == 'pool') {
            balance -= transaction.amount;
          }
          break;
        case TransactionType.sharedExpense:
          // Only reduce pool if pool participated
          if (transaction.paidBy == 'pool') {
            balance -= transaction.amount;
          }
          break;
        case TransactionType.poolExpense:
          // Pool expense reduces pool balance
          balance -= transaction.amount;
          break;
      }
    }
    
    return balance;
  }

  /// Calculate user debt to pool
  static double calculateUserDebt(String userId, List<Transaction> transactions) {
    double debt = 0;
    
    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.borrow:
          // Borrowing increases debt
          if (transaction.receivedBy == userId && transaction.paidBy == 'pool') {
            debt += transaction.amount;
          }
          break;
        case TransactionType.deposit:
          // Depositing reduces debt
          if (transaction.paidBy == userId && transaction.receivedBy == 'pool') {
            debt -= transaction.amount;
          }
          break;
        case TransactionType.sharedExpense:
          // Shared expense affects debt based on split
          if (transaction.splitType == SplitType.equal) {
            // Equal split between 2 users
            final halfAmount = transaction.amount / 2;
            if (transaction.paidBy == userId) {
              debt -= halfAmount; // User paid their half
            } else {
              debt += halfAmount; // User owes their half
            }
          } else if (transaction.splitType == SplitType.custom &&
              transaction.splitData != null) {
            // Custom split
            final userShare = transaction.splitData![userId] as double? ?? 0;
            if (transaction.paidBy == userId) {
              debt -= (transaction.amount - userShare);
            } else {
              debt += userShare;
            }
          }
          break;
        case TransactionType.poolExpense:
          // Pool expenses don't affect individual debt
          break;
      }
    }
    
    return debt;
  }

  /// Get user's borrow transactions
  static List<Transaction> getUserBorrows(
    String userId,
    List<Transaction> transactions,
  ) {
    return transactions
        .where((t) =>
            t.type == TransactionType.borrow && t.receivedBy == userId)
        .toList();
  }

  /// Get shared expenses for a user
  static List<Transaction> getUserSharedExpenses(
    String userId,
    List<Transaction> transactions,
  ) {
    return transactions
        .where((t) =>
            t.type == TransactionType.sharedExpense &&
            (t.paidBy == userId || t.receivedBy.contains(userId)))
        .toList();
  }

  /// Calculate monthly summary
  static MonthlySummary calculateMonthlySummary(
    List<Transaction> transactions,
    List<String> userIds,
    DateTime month,
  ) {
    // Filter transactions for the month
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

    final poolBalance = calculatePoolBalance(transactions);
    final userDebts = {
      for (final userId in userIds)
        userId: calculateUserDebt(userId, transactions)
    };

    return MonthlySummary(
      poolBalance: poolBalance,
      inflow: inflow,
      outflow: outflow,
      userDebts: userDebts,
    );
  }

  /// Get transactions for a trip
  static TripSummary getTripSummary(
    Trip trip,
    List<Transaction> transactions,
    List<String> userIds,
  ) {
    final tripTransactions = transactions
        .where((t) => t.tripId == trip.id)
        .toList();

    double totalCost = 0;
    final contributions = {for (final userId in userIds) userId: 0.0};

    for (final transaction in tripTransactions) {
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

    return TripSummary(
      trip: trip,
      expenses: tripTransactions,
      contributions: contributions,
      totalCost: totalCost,
    );
  }

  /// Validate transaction before save
  static String? validateTransaction(Transaction transaction) {
    if (transaction.description.isEmpty) {
      return 'Description is required';
    }
    if (transaction.amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (transaction.paidBy.isEmpty) {
      return 'Paid by is required';
    }
    if (transaction.receivedBy.isEmpty) {
      return 'Received by is required';
    }
    return null;
  }

  /// Calculate settlement needed between users
  static double getSettlementAmount(
    String userId1,
    String userId2,
    List<Transaction> transactions,
  ) {
    // How much does userId1 owe to userId2?
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

    return amount;
  }
}
