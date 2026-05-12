import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._supabase);

  final SupabaseClient _supabase;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  DateTime? _lastTransactionNoticeAt;
  DateTime? _lastLeaveNoticeAt;

  static const int _transactionChangedId = 3001;
  static const int _leaveChangedId = 3002;
  static const int _monthlySummaryBaseId = 4000;
  static const int _monthlySummaryCount = 24;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> syncMonthlyDebtSummaryNotifications() async {
    if (!_initialized) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final debt = await _fetchCurrentUserDebt(user.id);
    final amountLabel = NumberFormat.currency(symbol: r'$', decimalDigits: 2)
        .format(debt);

    for (var i = 0; i < _monthlySummaryCount; i++) {
      await _plugin.cancel(_monthlySummaryBaseId + i);
    }

    final now = DateTime.now();
    for (var i = 0; i < _monthlySummaryCount; i++) {
      final scheduledAt = _monthlyScheduleDate(now, i);
      if (!scheduledAt.isAfter(now)) continue;

      await _plugin.zonedSchedule(
        _monthlySummaryBaseId + i,
        'FUNd Monthly Summary',
        debt > 0
            ? 'You owe $amountLabel this month.'
            : 'No outstanding amount this month. Nice work.',
        tz.TZDateTime.from(scheduledAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'monthly_summary_channel',
            'Monthly Summary',
            channelDescription: 'Monthly debt summary notifications',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> notifyTransactionChanged() async {
    if (!_initialized || _shouldSkipDebounced(_lastTransactionNoticeAt)) return;
    _lastTransactionNoticeAt = DateTime.now();

    await _plugin.show(
      _transactionChangedId,
      'Transactions Updated',
      'A transaction was added, updated, or deleted.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'changes_channel',
          'Live Changes',
          channelDescription: 'Notifications for table changes',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> notifyLeavesChanged() async {
    if (!_initialized || _shouldSkipDebounced(_lastLeaveNoticeAt)) return;
    _lastLeaveNoticeAt = DateTime.now();

    await _plugin.show(
      _leaveChangedId,
      'Leave Records Updated',
      'A leave record was added, updated, or deleted.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'changes_channel',
          'Live Changes',
          channelDescription: 'Notifications for table changes',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<double> _fetchCurrentUserDebt(String userId) async {
    try {
      final data = await _supabase
          .from('user_debt')
          .select('debt')
          .eq('user_id', userId)
          .maybeSingle();
      return (data?['debt'] as num?)?.toDouble() ?? 0;
    } catch (e, st) {
      debugPrint('Failed to fetch debt for monthly summary: $e\n$st');
      return 0;
    }
  }

  DateTime _monthlyScheduleDate(DateTime base, int monthOffset) {
    final monthStart = DateTime(base.year, base.month + monthOffset, 1);
    final lastDay = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final day = min(31, lastDay);
    return DateTime(monthStart.year, monthStart.month, day, 9);
  }

  bool _shouldSkipDebounced(DateTime? last) {
    if (last == null) return false;
    return DateTime.now().difference(last).inSeconds < 20;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(Supabase.instance.client);
});
