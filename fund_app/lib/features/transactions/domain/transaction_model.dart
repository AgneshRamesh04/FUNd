enum TransactionType { borrow, deposit, sharedExpense, poolExpense }

class TransactionModel {
  final String id;
  final TransactionType type;
  final String description;
  final double amount;
  final String paidBy;
  final String receivedBy;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.receivedBy,
    required this.date,
  });
}