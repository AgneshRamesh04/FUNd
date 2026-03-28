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
            callback: (_) {
              _ref.invalidate(poolBalanceProvider);
              _ref.invalidate(userDebtsProvider);
              _ref.invalidate(inflowOutflowProvider);
              _ref.invalidate(personalTransactionsProvider);
              _ref.invalidate(poolMonthExpenseProvider);
              _ref.invalidate(sharedTransactionsProvider);
              _ref.invalidate(activeTripProvider);
              _ref.invalidate(allTripsProvider);
              _ref.invalidate(poolSummaryTotalProvider);
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
