import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_exception.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validation_utils.dart';
import 'personal_models.dart';

class PersonalRepository {
  final SupabaseClient supabase;
  PersonalRepository(this.supabase);

  static const int pageSize = 100;

  /// Fetches personal transactions for a specific month with pagination.
  Future<List<PersonalTransaction>> fetchPersonalTransactions({
    required String monthKey,
    int offset = 0,
  }) async {
    try {
      final data = await supabase
          .from('transactions')
          .select(
              'id, type, user_id, amount, description, date, notes, month_key')
          .inFilter('type', ['borrow', 'monthly_obligation', 'deposit'])
          .eq('month_key', monthKey)
          .order('date', ascending: false)
          .range(offset, offset + pageSize - 1);
      return (data).map(PersonalTransaction.fromJson).toList();
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

  /// Returns a userId → name map from the users table.
  Future<Map<String, String>> fetchUserNames() async {
    try {
      final data = await supabase.from('users').select('id, name');
      return {
        for (final u in data as List)
          u['id'] as String: (u['name'] as String?) ?? 'Unknown'
      };
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

  /// Creates a personal transaction (borrow).
  /// Sanitizes all user inputs before database insertion
  Future<void> createPersonalTransaction({
    required String userId,
    required double amount,
    required String description,
    required DateTime date,
    required String monthKey,
    String? notes,
  }) async {
    try {
      // Validate inputs
      if (!ValidationUtils.isValidAmount(amount)) {
        throw AppException.validation('Amount must be greater than 0');
      }
      if (!ValidationUtils.isValidUserId(userId)) {
        throw AppException.validation('User ID cannot be empty');
      }
      if (!ValidationUtils.isValidDescription(description)) {
        throw AppException.validation('Description cannot be empty');
      }
      
      // Sanitize inputs
      final sanitizedDescription = ValidationUtils.sanitizeInput(description);
      final sanitizedNotes = notes != null ? ValidationUtils.sanitizeInput(notes) : null;
      
      await supabase.from('transactions').insert({
        'type': 'borrow',
        'user_id': userId,
        'amount': amount,
        'description': sanitizedDescription,
        'date': DateUtils.toDateString(date),
        'month_key': monthKey,
        'notes': sanitizedNotes,
      });
    } catch (e, st) {
      if (e is AppException) rethrow;
      throw AppException.fromError(e, st);
    }
  }
}
