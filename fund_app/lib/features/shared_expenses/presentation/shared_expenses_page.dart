import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/username_utils.dart';
import '../../../shared/providers/current_user_provider.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../transactions/data/transaction_service.dart';
import '../data/shared_expenses_models.dart';
import '../data/shared_expenses_providers.dart';
import 'widgets/shared_transaction_tile.dart';

class SharedExpensesPage extends ConsumerWidget {
  const SharedExpensesPage({super.key, required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final poolSummaryAsync = ref.watch(poolSummaryTotalProvider(selectedMonth));
    final tripAsync = ref.watch(activeTripProvider);
    final allTripsAsync = ref.watch(allTripsProvider);
    // Generate month key in YYYY-MM format
    final monthKey = app_date.DateUtils.toMonthKey(selectedMonth).substring(0, 7);
    final txState = ref.watch(sharedTransactionsProvider(monthKey));
    final userNames = ref.watch(sharedUserNamesProvider).value ?? {};
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.maybeWhen(
      data: (user) => user.id,
      orElse: () => '',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Section 1: Total shared expense for the month ─────────────────
          Text('SHARED THIS MONTH', style: theme.textTheme.labelMedium),
          const SizedBox(height: 10),
          poolSummaryAsync.when(
            data: (total) => _PoolSummaryCard(
              month: selectedMonth,
              totalExpense: total,
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorState(message: '$e'),
          ),
          const SizedBox(height: 28),

          // ── Section 2: Active trip ─────────────────────────────────────
          Text('ACTIVE TRIP', style: theme.textTheme.labelMedium),
          const SizedBox(height: 10),
          tripAsync.when(
            data: (trip) => trip != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TripCard(trip: trip),
                      const SizedBox(height: 12),
                      allTripsAsync.when(
                        data: (trips) {
                          if (trips.length <= 1) return const SizedBox.shrink();
                          return SizedBox(
                            height: 40,
                            child: TextButton(
                              onPressed: () =>
                                  _showAllTripsModal(context, trips, theme),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    AppTheme.accent.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'View all trips',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _NoTripCard(),
                      const SizedBox(height: 12),
                      allTripsAsync.when(
                        data: (trips) {
                          if (trips.isEmpty) return const SizedBox.shrink();
                          return SizedBox(
                            height: 40,
                            child: TextButton(
                              onPressed: () =>
                                  _showAllTripsModal(context, trips, theme),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    AppTheme.accent.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'View all trips',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorState(message: '$e'),
          ),
          const SizedBox(height: 28),

          // ── Section 3: Shared transactions (no trip) ──────────────────
          Text('SHARED EXPENSES', style: theme.textTheme.labelMedium),
          const SizedBox(height: 12),
          Builder(builder: (_) {
            if (txState.isLoading) {
              return const TransactionListSkeleton();
            }
            if (txState.error != null) {
              return ErrorState(
                message: txState.error ?? 'Failed to load transactions',
              );
            }
            if (txState.transactions.isEmpty) {
              return const TransactionEmptyState();
            }

            // Transactions are already filtered by the provider (backend query)
            return Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerTheme.color ?? Colors.transparent,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(txState.transactions.length, (i) {
                    final tx = txState.transactions[i];
                    return SharedTransactionTile(
                      tx: tx,
                      userName: getDisplayName(
                        tx.userId ?? '',
                        currentUserId,
                        userNames,
                      ),
                      showDivider: i < txState.transactions.length - 1,
                      onEdit: () => _showEditSharedTransactionDialog(context, ref, tx),
                      onDelete: () => _confirmDeleteSharedTransaction(context, ref, tx),
                    );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSharedTransaction(
    BuildContext context,
    WidgetRef ref,
    SharedTransaction tx,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm delete'),
          content: const Text('Delete this transaction? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(transactionServiceProvider).deleteSharedTransaction(tx.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shared transaction deleted')),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showEditSharedTransactionDialog(
    BuildContext context,
    WidgetRef ref,
    SharedTransaction tx,
  ) async {
    final amountController = TextEditingController(text: tx.amount.toStringAsFixed(2));
    final descController = TextEditingController(text: tx.description ?? '');
    final notesController = TextEditingController(text: tx.notes ?? '');

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Shared Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
          ],
        );
      },
    );

    if (submitted != true || !context.mounted) return;

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid amount')),
      );
      return;
    }

    final desc = descController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description cannot be empty')),
      );
      return;
    }

    try {
      await ref.read(transactionServiceProvider).updateSharedTransaction(
            id: tx.id,
            type: tx.type,
            userId: tx.userId,
            amount: amount,
            description: desc,
            date: tx.date,
            monthKey: tx.monthKey ?? app_date.DateUtils.toMonthKey(tx.date),
            notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shared transaction updated')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${e.toString()}')),
      );
    }
  }

  void _showAllTripsModal(
      BuildContext context, List<TripSummary> trips, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Trips',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (trips.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No trips found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.labelMedium?.color,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: List.generate(trips.length, (i) {
                    final trip = trips[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TripCard(trip: trip),
                    );
                  }),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Pool summary card ────────────────────────────────────────────────────────

class _PoolSummaryCard extends StatelessWidget {
  const _PoolSummaryCard({
    required this.month,
    required this.totalExpense,
  });

  final DateTime month;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat('#,##0.00');

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
          Text(
            'SGD ${fmt.format(totalExpense)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total expenses for ${DateFormat.MMMM().format(month)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.labelMedium?.color,
            ),
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


