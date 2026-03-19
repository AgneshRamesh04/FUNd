import 'package:fund_app/core/models/transaction_model.dart';
import 'package:fund_app/core/services/supabase_service.dart';
import 'package:fund_app/core/constants/app_constants.dart';

class TransactionService {
  final SupabaseService _supabaseService;

  TransactionService(this._supabaseService);

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
    final now = DateTime.now();
    final data = {
      'type': type.toString().split('.').last,
      'description': description,
      'amount': amount,
      'paid_by': paidBy,
      'received_by': receivedBy,
      'split_type': splitType?.toString().split('.').last,
      'split_data': splitData,
      'date': date.toIso8601String(),
      'trip_id': tripId,
      'notes': notes,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _supabaseService.client
        .from(AppConstants.transactionsTable)
        .insert(data)
        .select()
        .single();

    return Transaction.fromJson(response);
  }

  Future<Transaction> updateTransaction({
    required String transactionId,
    String? description,
    double? amount,
    String? paidBy,
    String? receivedBy,
    DateTime? date,
    String? notes,
  }) async {
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (description != null) updateData['description'] = description;
    if (amount != null) updateData['amount'] = amount;
    if (paidBy != null) updateData['paid_by'] = paidBy;
    if (receivedBy != null) updateData['received_by'] = receivedBy;
    if (date != null) updateData['date'] = date.toIso8601String();
    if (notes != null) updateData['notes'] = notes;

    final response = await _supabaseService.client
        .from(AppConstants.transactionsTable)
        .update(updateData)
        .eq('id', transactionId)
        .select()
        .single();

    return Transaction.fromJson(response);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _supabaseService.client
        .from(AppConstants.transactionsTable)
        .delete()
        .eq('id', transactionId);
  }

  Future<List<Transaction>> getTransactions({
    String? tripId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      final response = await _supabaseService.client
          .from(AppConstants.transactionsTable)
          .select()
          .order('date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    }
  }

  Stream<List<Transaction>> watchTransactions({
    String? tripId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _supabaseService.client
        .from(AppConstants.transactionsTable)
        .stream(primaryKey: ['id'])
        .map((list) {
          return list
              .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
              .toList();
        });
  }
}
