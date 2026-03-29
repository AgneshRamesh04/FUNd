import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_exception.dart';
import '../../../core/utils/date_utils.dart';
import 'shared_expenses_models.dart';

class SharedExpensesRepository {
  final SupabaseClient supabase;
  SharedExpensesRepository(this.supabase);

  static const int pageSize = 100;

  /// Totals for user_paid_for_pool and pool_expense for the given month.
  Future<Map<String, double>> fetchPoolMonthExpense(DateTime month) async {
    try {
      final startStr = DateUtils.toMonthKey(month);
      final endStr = DateUtils.toMonthKey(DateUtils.nextMonth(month));

      final data = await supabase
          .from('transactions')
          .select('type, amount')
          .inFilter('type', ['user_paid_for_pool', 'pool_expense'])
          .gte('date', startStr)
          .lt('date', endStr);

      double contributed = 0;
      double spent = 0;
      for (final row in data as List) {
        final amt = (row['amount'] as num?)?.toDouble() ?? 0.0;
        if (row['type'] == 'user_paid_for_pool') {
          contributed += amt;
        } else {
          spent += amt;
        }
      }
      return {'contributed': contributed, 'spent': spent};
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

  /// Fetches the total shared expense for the month from pool_summary table.
  Future<double> fetchPoolSummaryTotal(DateTime month) async {
    try {
      final monthStr = DateUtils.toMonthKey(month);
      print("fetching pool summary total for month: $monthStr");
      final data = await supabase
          .from('pool_summary')
          .select('shared_expense')
          .eq('month', monthStr)
          .limit(1);

      print("pool summary total response: $data");

      if ((data as List).isEmpty) return 0.0;
      return (data.first['shared_expense'] as num?)?.toDouble() ?? 0.0;
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

  /// Returns the most relevant trip: ongoing → nearest upcoming → most recent past.
  Future<TripSummary?> fetchActiveTripSummary() async {
    try {
      final data = await supabase
          .from('trip_summary')
          .select(
              'trip_id, trip_name, start_date, end_date, duration_days, total_expense')
          .order('start_date', ascending: false)
          .limit(20);

      final trips = (data as List)
          .map((e) => TripSummary.fromJson(e as Map<String, dynamic>))
          .toList();
      if (trips.isEmpty) return null;

      final today = DateUtils.startOfDay(DateTime.now());

      // 1. Ongoing
      final ongoing = trips
          .where((t) =>
              t.startDate != null &&
              !t.startDate!.isAfter(today) &&
              (t.endDate == null || !t.endDate!.isBefore(today)))
          .firstOrNull;
      if (ongoing != null) return ongoing;

      // 2. Nearest upcoming
      final upcoming = trips
          .where((t) => t.startDate != null && t.startDate!.isAfter(today))
          .toList()
        ..sort((a, b) => a.startDate!.compareTo(b.startDate!));
      if (upcoming.isNotEmpty) return upcoming.first;

      // 3. Most recent past
      return trips.first;
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

  /// Paginated shared transactions for a specific month with no trip assignment (trip_id IS NULL).
  Future<List<SharedTransaction>> fetchSharedTransactions({
    required String monthKey,
    int offset = 0,
  }) async {
    try {
      final data = await supabase
          .from('transactions')
          .select(
              'id, type, user_id, amount, description, date, notes, month_key')
          .inFilter('type', ['user_paid_for_pool', 'pool_expense'])
          .eq('month_key', monthKey)
          .filter('trip_id', 'is', 'null')
          .order('date', ascending: false)
          .range(offset, offset + pageSize - 1);
      return (data as List)
          .map((e) => SharedTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

  /// Fetches all trips from trip_summary, sorted by start_date descending.
  Future<List<TripSummary>> fetchAllTrips() async {
    try {
      final data = await supabase
          .from('trip_summary')
          .select(
              'trip_id, trip_name, start_date, end_date, duration_days, total_expense')
          .order('start_date', ascending: false);

      return (data as List)
          .map((e) => TripSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

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
}
