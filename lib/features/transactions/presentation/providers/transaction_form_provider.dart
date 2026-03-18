import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';

/// State notifier for creating/updating transactions
class TransactionFormNotifier extends StateNotifier<TransactionEntity?> {
  TransactionFormNotifier() : super(null);

  void setTransaction(TransactionEntity? transaction) {
    state = transaction;
  }

  void reset() {
    state = null;
  }
}

final transactionFormProvider = StateNotifierProvider<
    TransactionFormNotifier,
    TransactionEntity?>((ref) {
  return TransactionFormNotifier();
});
