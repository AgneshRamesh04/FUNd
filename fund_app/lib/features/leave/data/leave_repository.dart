import 'package:supabase_flutter/supabase_flutter.dart';
import 'leave_models.dart';

class LeaveRepository {
  final SupabaseClient _supabase;

  LeaveRepository(this._supabase);

  // ─────────────────────────────────────────────────────────────────────
  // Leave Entries
  // ─────────────────────────────────────────────────────────────────────

  Future<void> createLeaveEntry({
    required String userId,
    required String description,
    required int daysUsed,
    required DateTime leaveDate,
    String? tripId,
  }) async {
    try {
      await _supabase.from('leave_entries').insert({
        'user_id': userId,
        'trip_id': tripId,
        'description': description,
        'days_used': daysUsed,
        'leave_date': leaveDate.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create leave entry: $e');
    }
  }

  Future<List<LeaveEntry>> getLeaveEntriesByUser(String userId) async {
    try {
      final response = await _supabase
          .from('leave_entries')
          .select()
          .eq('user_id', userId)
          .order('leave_date', ascending: false);

      return (response as List)
          .map((json) => LeaveEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch leave entries: $e');
    }
  }

  Future<List<LeaveEntry>> getLeaveEntriesByYear(
    String userId,
    int year,
  ) async {
    try {
      final startDate = DateTime.utc(year, 1, 1).toIso8601String();
      final nextYearStartDate = DateTime.utc(year + 1, 1, 1).toIso8601String();

      final response = await _supabase
          .from('leave_entries')
          .select()
          .eq('user_id', userId)
          .gte('leave_date', startDate)
          .lt('leave_date', nextYearStartDate)
          .order('leave_date', ascending: false);

      return (response as List)
          .map((json) => LeaveEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch leave entries by year: $e');
    }
  }

  Future<void> deleteLeaveEntry(String id) async {
    try {
      await _supabase.from('leave_entries').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete leave entry: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Leave Tracking
  // ─────────────────────────────────────────────────────────────────────

  Future<LeaveTracking?> getLeaveTracking(String userId, int year) async {
    try {
      final response = await _supabase
          .from('leave_tracking')
          .select()
          .eq('user_id', userId)
          .eq('year', year)
          .maybeSingle();

      if (response == null) return null;
      return LeaveTracking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch leave tracking: $e');
    }
  }

  Future<LeaveTracking> createOrGetLeaveTracking(
    String userId,
    int year,
  ) async {
    try {
      // Try to get existing
      final existing = await getLeaveTracking(userId, year);
      if (existing != null) return existing;

      // Create new
      final response = await _supabase
          .from('leave_tracking')
          .insert({'user_id': userId, 'year': year, 'used': 0, 'total': 0})
          .select()
          .single();

      return LeaveTracking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create or get leave tracking: $e');
    }
  }

  Future<void> updateLeaveTrackingTotal({
    required String userId,
    required int year,
    required int total,
  }) async {
    try {
      // Ensure record exists
      final existing = await getLeaveTracking(userId, year);

      if (existing != null) {
        await _supabase
            .from('leave_tracking')
            .update({'total': total})
            .eq('id', existing.id);
      } else {
        await createOrGetLeaveTracking(userId, year);
        await _supabase
            .from('leave_tracking')
            .update({'total': total})
            .eq('user_id', userId)
            .eq('year', year);
      }
    } catch (e) {
      throw Exception('Failed to update leave tracking total: $e');
    }
  }

  Future<List<LeaveTracking>> getLeaveTrackingForUser(String userId) async {
    try {
      final response = await _supabase
          .from('leave_tracking')
          .select()
          .eq('user_id', userId)
          .order('year', ascending: false);

      return (response as List)
          .map((json) => LeaveTracking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch leave tracking: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Leave Summary (View)
  // ─────────────────────────────────────────────────────────────────────

  Future<LeaveSummary?> getLeaveSummary(String userId, int year) async {
    try {
      final response = await _supabase
          .from('leave_summary')
          .select()
          .eq('user_id', userId)
          .eq('year', year)
          .maybeSingle();

      if (response == null) return null;
      return LeaveSummary.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch leave summary: $e');
    }
  }

  Future<List<LeaveSummary>> getAllLeaveSummary(int year) async {
    try {
      final response = await _supabase
          .from('leave_summary')
          .select()
          .eq('year', year)
          .order('username', ascending: true);

      return (response as List)
          .map((json) => LeaveSummary.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch leave summary: $e');
    }
  }
}
