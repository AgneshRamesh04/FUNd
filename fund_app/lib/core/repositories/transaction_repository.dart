import 'package:fund_app/core/models/transaction_model.dart';
import 'package:fund_app/core/services/transaction_service.dart';

class TransactionRepository {
  final TransactionService _transactionService;

  TransactionRepository(this._transactionService);

  Future<Transaction> createTransaction({
    required TransactionType type,
    required String description,
    required double amount,
    required String paidBy,
    String? receivedBy,
    SplitType? splitType,
    Map<String, dynamic>? splitData,
    required DateTime date,
    String? tripId,
    String? notes,
  }) async {
    return _transactionService.createTransaction(
      type: type,
      description: description,
      amount: amount,
      paidBy: paidBy,
      receivedBy: receivedBy,
      splitType: splitType,
      splitData: splitData,
      date: date,
      tripId: tripId,
      notes: notes,
    );
  }

  Future<Transaction> updateTransaction({
    required String transactionId,
    String? description,
    double? amount,
    String? paidBy,
    String? receivedBy,
    DateTime? date,
    String? notes,
  }) {
    return _transactionService.updateTransaction(
      transactionId: transactionId,
      description: description,
      amount: amount,
      paidBy: paidBy,
      receivedBy: receivedBy,
      date: date,
      notes: notes,
    );
  }

  Future<void> deleteTransaction(String transactionId) {
    return _transactionService.deleteTransaction(transactionId);
  }

  Future<List<Transaction>> getTransactions({
    String? tripId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) {
    return _transactionService.getTransactions(
      tripId: tripId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  Stream<List<Transaction>> watchTransactions({
    String? tripId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _transactionService.watchTransactions(
      tripId: tripId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
