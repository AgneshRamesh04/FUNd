import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_exception.dart';
import '../../../core/utils/date_utils.dart';
import 'home_models.dart';

class HomeRepository {
  final SupabaseClient supabase;
  HomeRepository(this.supabase);

  Future<double> fetchPoolBalance() async {
    try {
      final response =
          await supabase.from('pool_balance').select('pool_balance').single();
      return (response['pool_balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

  Future<List<UserDebt>> fetchUserDebts() async {
    try {
      final data =
          await supabase.from('user_debt').select('user_id, username, debt');
      return (data as List)
          .map((d) => UserDebt.fromJson(d as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

  Future<List<UserLeave>> fetchUserLeaves(int year) async {
    try {
      final data = await supabase
          .from('leave_summary')
          .select('user_id, username, used, total, year')
          .eq('year', year);
      return (data as List)
          .map((d) => UserLeave.fromJson(d as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }

  Future<Map<String, double>> fetchMonthlyInflowOutflow(DateTime month) async {
    try {
      final monthStr = DateUtils.toMonthKey(month);
      final data = await supabase
          .from('pool_summary')
          .select('monthly_inflow, monthly_outflow')
          .eq('month', monthStr)
          .maybeSingle();

      return {
        'inflow': (data?['monthly_inflow'] as num?)?.toDouble() ?? 0.0,
        'outflow': (data?['monthly_outflow'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e, st) {
      throw AppException.fromError(e, st);
    }
  }
}
