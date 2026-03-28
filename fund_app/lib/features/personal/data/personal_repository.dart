import 'package:supabase_flutter/supabase_flutter.dart';

import 'personal_models.dart';

class PersonalRepository {
  final SupabaseClient supabase;
  PersonalRepository(this.supabase);

  static const int pageSize = 100;

  Future<List<PersonalTransaction>> fetchPersonalTransactions({
    int offset = 0,
  }) async {
    final data = await supabase
        .from('transactions')
        .select(
            'id, type, user_id, amount, description, date, notes, month_key')
        .inFilter('type', ['borrow', 'monthly_obligation', 'deposit'])
        .order('date', ascending: false)
        .range(offset, offset + pageSize - 1);
    return (data).map(PersonalTransaction.fromJson).toList();
  }

  /// Returns a userId → name map from the users table.
  Future<Map<String, String>> fetchUserNames() async {
    final data = await supabase.from('users').select('id, name');
    return {
      for (final u in data as List)
        u['id'] as String: (u['name'] as String?) ?? 'Unknown'
    };
  }
}
