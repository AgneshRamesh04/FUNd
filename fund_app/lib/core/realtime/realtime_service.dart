import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../notifications/notification_service.dart';
import '../../features/home/data/home_providers.dart';
import '../../features/personal/data/personal_providers.dart';
import '../../features/shared_expenses/data/shared_expenses_providers.dart';

class RealtimeService {
  final SupabaseClient _supabase;
  final Ref _ref;
  final NotificationService _notificationService;
  final List<RealtimeChannel> _channels = [];

  RealtimeService(this._supabase, this._ref, this._notificationService);

  /// Opens one channel per underlying table. Safe to call only when
  /// [_channels] is empty (i.e. after [unsubscribe] has completed).
  void subscribe() {
    assert(
      _channels.isEmpty,
      'RealtimeService.subscribe() called while channels are still open. '
      'Await unsubscribe() first.',
    );

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
              _notificationService.notifyTransactionChanged();
              _notificationService.syncMonthlyDebtSummaryNotifications();

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

              // Trip list and trip expenses may be affected by transaction trip assignment.
              if (record.containsKey('trip_id')) {
                final tripId = record['trip_id'] as String?;
                _ref.invalidate(activeTripProvider);
                _ref.invalidate(allTripsProvider);
                // Invalidate the specific trip's expenses provider
                if (tripId != null && tripId.isNotEmpty) {
                  _ref.invalidate(tripExpensesProvider(tripId));
                }
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

    // ── leave_entries / leave_tracking / leave_summary → home leave cards ──
    _channels.add(
      _supabase
          .channel('db-leave-entries')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'leave_entries',
            callback: (payload) {
              final year = _extractLeaveYearFromPayload(payload);
              _ref.invalidate(userLeavesProvider(year));
              _notificationService.notifyLeavesChanged();
            },
          )
          .subscribe(),
    );

    _channels.add(
      _supabase
          .channel('db-leave-tracking')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'leave_tracking',
            callback: (payload) {
              final year = _extractLeaveYearFromPayload(payload);
              _ref.invalidate(userLeavesProvider(year));
              _notificationService.notifyLeavesChanged();
            },
          )
          .subscribe(),
    );

    _channels.add(
      _supabase
          .channel('db-leave-summary')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'leave_summary',
            callback: (payload) {
              final year = _extractLeaveYearFromPayload(payload);
              _ref.invalidate(userLeavesProvider(year));
              _notificationService.notifyLeavesChanged();
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

  int _extractLeaveYearFromPayload(PostgresChangePayload payload) {
    final record = payload.newRecord.isNotEmpty
        ? payload.newRecord
        : payload.oldRecord;

    final rawYear = record['year'];
    if (rawYear is int) return rawYear;
    if (rawYear is String) {
      final parsed = int.tryParse(rawYear);
      if (parsed != null) return parsed;
    }

    final rawLeaveDate = record['leave_date'];
    if (rawLeaveDate is String) {
      final parsedDate = DateTime.tryParse(rawLeaveDate);
      if (parsedDate != null) return parsedDate.year;
    }

    return DateTime.now().year;
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
  return RealtimeService(
    Supabase.instance.client,
    ref,
    ref.watch(notificationServiceProvider),
  );
});
