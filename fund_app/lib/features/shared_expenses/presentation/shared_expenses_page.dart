import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../data/shared_expenses_models.dart';
import '../data/shared_expenses_providers.dart';
import 'widgets/shared_transaction_tile.dart';

class SharedExpensesPage extends ConsumerWidget {
  const SharedExpensesPage({super.key, required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final poolExpenseAsync =
        ref.watch(poolMonthExpenseProvider(selectedMonth));
    final tripAsync = ref.watch(activeTripProvider);
    final txState = ref.watch(sharedTransactionsProvider);
    final userNames = ref.watch(sharedUserNamesProvider).value ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Section 1: Pool expenses this month ───────────────────────
          Text('POOL EXPENSES', style: theme.textTheme.labelMedium),
          const SizedBox(height: 10),
          poolExpenseAsync.when(
            data: (data) => _PoolMonthCard(
              month: selectedMonth,
              contributed: data['contributed'] ?? 0,
              spent: data['spent'] ?? 0,
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => _ErrorText('$e'),
          ),
          const SizedBox(height: 28),

          // ── Section 2: Active trip ─────────────────────────────────────
          Text('ACTIVE TRIP', style: theme.textTheme.labelMedium),
          const SizedBox(height: 10),
          tripAsync.when(
            data: (trip) =>
                trip != null ? _TripCard(trip: trip) : _NoTripCard(),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => _ErrorText('$e'),
          ),
          const SizedBox(height: 28),

          // ── Section 3: Shared transactions (no trip) ──────────────────
          Text('SHARED EXPENSES', style: theme.textTheme.labelMedium),
          const SizedBox(height: 12),
          Builder(builder: (_) {
            if (txState.isLoading) {
              return const Padding(
                padding: EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(),
              );
            }
            if (txState.error != null) return _ErrorText(txState.error!);
            if (txState.transactions.isEmpty) return _EmptyState();

            final Map<String, List<SharedTransaction>> grouped = {};
            for (final tx in txState.transactions) {
              (grouped[tx.resolvedMonthKey] ??= []).add(tx);
            }
            final keys = grouped.keys.toList();

            return Column(
              children: [
                ...keys.map((monthKey) {
                  final group = grouped[monthKey]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _monthLabel(monthKey),
                                style:
                                    theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.dividerTheme.color ??
                                Colors.transparent,
                          ),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: List.generate(group.length, (i) {
                            return SharedTransactionTile(
                              tx: group[i],
                              userName:
                                  userNames[group[i].userId] ?? 'Unknown',
                              showDivider: i < group.length - 1,
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
                // Load more footer
                if (txState.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: CircularProgressIndicator.adaptive()),
                  )
                else if (txState.hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Center(
                      child: TextButton(
                        onPressed: () => ref
                            .read(sharedTransactionsProvider.notifier)
                            .loadMore(),
                        child: const Text(
                          'Load more',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _monthLabel(String key) {
    try {
      final parts = key.split('-');
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat.yMMMM().format(dt);
    } catch (_) {
      return key;
    }
  }
}

// ── Pool month summary card ───────────────────────────────────────────────────

class _PoolMonthCard extends StatelessWidget {
  const _PoolMonthCard({
    required this.month,
    required this.contributed,
    required this.spent,
  });

  final DateTime month;
  final double contributed;
  final double spent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat('#,##0.00');
    final net = contributed - spent;
    final netPositive = net >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONTRIBUTED',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.positive,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '+SGD ${fmt.format(contributed)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.positive,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  width: 1,
                  height: 36,
                  color: theme.dividerTheme.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SPENT',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.negative,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '-SGD ${fmt.format(spent)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.negative,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: theme.dividerTheme.color),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net for ${DateFormat.yMMMM().format(month)}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.textTheme.labelMedium?.color)),
              Text(
                '${netPositive ? '+' : ''}SGD ${fmt.format(net)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: netPositive ? AppTheme.positive : AppTheme.negative,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Trip card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat('#,##0.00');
    final dateFmt = DateFormat('MMM d');
    final yearFmt = DateFormat('MMM d, y');

    String dateRange = '—';
    if (trip.startDate != null && trip.endDate != null) {
      dateRange =
          '${dateFmt.format(trip.startDate!)} – ${yearFmt.format(trip.endDate!)}';
    } else if (trip.startDate != null) {
      dateRange = yearFmt.format(trip.startDate!);
    }

    final (statusLabel, statusColor) = switch (trip.status) {
      TripStatus.ongoing => ('ONGOING', AppTheme.positive),
      TripStatus.upcoming => ('UPCOMING', AppTheme.accent),
      TripStatus.past => ('PAST', const Color(0xFF9CA3AF)),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.tripName ?? 'Unnamed Trip',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14,
                  color: theme.textTheme.labelMedium?.color),
              const SizedBox(width: 6),
              Text(dateRange,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.textTheme.labelMedium?.color)),
              if (trip.durationDays != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.access_time_rounded,
                    size: 14,
                    color: theme.textTheme.labelMedium?.color),
                const SizedBox(width: 6),
                Text(
                  '${trip.durationDays} day${trip.durationDays == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.labelMedium?.color),
                ),
              ],
            ],
          ),
          if (trip.totalExpense != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 14,
                    color: theme.textTheme.labelMedium?.color),
                const SizedBox(width: 6),
                Text(
                  'SGD ${fmt.format(trip.totalExpense!)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(' total expenses',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.labelMedium?.color)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty states ──────────────────────────────────────────────────────────────

class _NoTripCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.luggage_rounded,
              size: 32,
              color: theme.textTheme.labelMedium?.color),
          const SizedBox(width: 14),
          Text(
            'No trips found',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.textTheme.labelMedium?.color),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 36,
              color: theme.textTheme.labelMedium?.color),
          const SizedBox(height: 12),
          Text(
            'No shared expenses',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.labelMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $message',
            style: const TextStyle(color: AppTheme.negative)),
      );
}
