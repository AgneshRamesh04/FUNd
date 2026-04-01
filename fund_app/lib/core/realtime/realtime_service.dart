import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/home/data/home_providers.dart';
import '../../features/personal/data/personal_providers.dart';
import '../../features/shared_expenses/data/shared_expenses_providers.dart';

class RealtimeService {
  final SupabaseClient _supabase;
  final Ref _ref;
  final List<RealtimeChannel> _channels = [];

  RealtimeService(this._supabase, this._ref);

  /// Opens one channel per underlying table. Safe to call only when
  /// [_channels] is empty (i.e. after [unsubscribe] has completed).
  void subscribe() {
    assert(
        _channels.isEmpty,
        'RealtimeService.subscribe() called while channels are still open. '
        'Await unsubscribe() first.');

    // ── transactions → pool_summary (balance + inflow/outflow) + user_debt ──
    _channels.add(
      _supabase
          .channel('db-transactions')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'transactions',
            callback: (payload) {
              _invalidateGlobalTransactionProviders();

              final record = payload.newRecord.isNotEmpty
                  ? payload.newRecord
                  : payload.oldRecord;
              final type = record['type'] as String?;
              final monthKey = record['month_key'] as String?;
              final monthDate = _monthKeyAsDateTime(monthKey);
              final monthFamilyKey = monthKey != null && monthKey.length >= 7
                  ? monthKey.substring(0, 7)
                  : null;

              // Pool/personal grid refresh by month.
              if (monthDate != null) {
                _ref.invalidate(inflowOutflowProvider(monthDate));
                _ref.invalidate(poolMonthExpenseProvider(monthDate));
                _ref.invalidate(poolSummaryTotalProvider(monthDate));
              }

              if (monthFamilyKey != null) {
                _ref.invalidate(sharedTransactionsProvider(monthFamilyKey));
                _ref.invalidate(personalTransactionsProvider(monthFamilyKey));
              }

              // Trip list may be affected by transaction trip assignment.
              if (record.containsKey('trip_id')) {
                _ref.invalidate(activeTripProvider);
                _ref.invalidate(allTripsProvider);
              }

              // Type-specific after-month invalidations
              if (type == 'borrow' && monthFamilyKey != null) {
                _ref.invalidate(personalTransactionsProvider(monthFamilyKey));
              } else if (monthFamilyKey != null &&
                  (type == 'user_paid_for_pool' ||
                      type == 'pool_expense' ||
                      type == 'deposit')) {
                _ref.invalidate(sharedTransactionsProvider(monthFamilyKey));
              }
            },
          )
          .subscribe(),
    );


    // ── trips → trip_summary (provider not yet implemented) ──────────────────
    _channels.add(
      _supabase
          .channel('db-trips')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'trips',
            callback: (_) {
              _ref.invalidate(activeTripProvider);
              _ref.invalidate(allTripsProvider);
            },
          )
          .subscribe(),
    );

    // ── leave_tracking → leave_summary ───────────────────────────────────────
    _channels.add(
      _supabase
          .channel('db-leave-tracking')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'leave_tracking',
            callback: (_) {
              _ref.invalidate(userLeavesProvider);
            },
          )
          .subscribe(),
    );
  }

  DateTime? _monthKeyAsDateTime(String? monthKey) {
    if (monthKey == null || monthKey.isEmpty) return null;

    final normalized = monthKey.length == 7 ? '$monthKey-01' : monthKey;
    return DateTime.tryParse(normalized);
  }

  void _invalidateGlobalTransactionProviders() {
    _ref.invalidate(poolBalanceProvider);
    _ref.invalidate(userDebtsProvider);
    _ref.invalidate(activeTripProvider);
    _ref.invalidate(allTripsProvider);
  }

  /// Removes all open channels and clears the list.
  /// Must be awaited before calling [subscribe] again.
  Future<void> unsubscribe() async {
    for (final channel in _channels) {
      await _supabase.removeChannel(channel);
    }
    _channels.clear();
  }
}

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService(Supabase.instance.client, ref);
});
