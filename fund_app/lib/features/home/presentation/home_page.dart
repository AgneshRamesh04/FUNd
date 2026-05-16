import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/current_user_provider.dart';
import '../../../shared/ui/app_ui.dart';
import '../../leave/presentation/leave_page.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../data/home_models.dart';
import '../data/home_providers.dart';
import 'widgets/debt_card.dart';
import 'widgets/inflow_outflow_card.dart';
import 'widgets/leave_card.dart';
import 'widgets/pool_balance_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
    required this.selectedMonth,
    this.onOpenPersonalTab,
  });

  final DateTime selectedMonth;
  final VoidCallback? onOpenPersonalTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolBalanceAsync = ref.watch(poolBalanceProvider);
    final debtsAsync = ref.watch(userDebtsProvider);
    final leaves =
        ref.watch(userLeavesProvider(selectedMonth.year)).value ?? [];
    final inflowOutflowAsync = ref.watch(inflowOutflowProvider(selectedMonth));
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.maybeWhen(
      data: (user) => user.id,
      orElse: () => '',
    );

    return SingleChildScrollView(
      padding: AppUi.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pool Balance Card
          poolBalanceAsync.when(
            data: (balance) => PoolBalanceCard(balance: balance),
            loading: () => const CardSkeleton(),
            error: (e, st) => ErrorState(message: e.toString()),
          ),
          const SizedBox(height: AppUi.itemGap),
          // Inflow/Outflow Cards
          Row(
            children: [
              Expanded(
                child: inflowOutflowAsync.when(
                  data: (inflowOutflow) => InflowOutflowCard(
                    title: 'INFLOW',
                    amount: inflowOutflow['inflow'] ?? 0.0,
                    positive: true,
                    onTap: () =>
                        _showFlowTransactions(context, _FlowSheetType.inflow),
                  ),
                  loading: () => const CardSkeleton(),
                  error: (e, st) => ErrorState(message: e.toString()),
                ),
              ),
              const SizedBox(width: AppUi.compactGap),
              Expanded(
                child: inflowOutflowAsync.when(
                  data: (inflowOutflow) => InflowOutflowCard(
                    title: 'OUTFLOW',
                    amount: inflowOutflow['outflow'] ?? 0.0,
                    positive: false,
                    onTap: () =>
                        _showFlowTransactions(context, _FlowSheetType.outflow),
                  ),
                  loading: () => const CardSkeleton(),
                  error: (e, st) => ErrorState(message: e.toString()),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppUi.itemGap),
          // Debt Card
          debtsAsync.when(
            data: (debts) => debts.isEmpty
                ? const DebtEmptyState()
                : DebtCard(
                    debts: debts
                        .map(
                          (d) => Debt(
                            userId: d.userId,
                            userName: d.userName,
                            amount: d.amount,
                          ),
                        )
                        .toList(),
                    currentUserId: currentUserId,
                    onTap: onOpenPersonalTab,
                  ),
            loading: () => const CardSkeleton(),
            error: (e, st) => ErrorState(message: e.toString()),
          ),
          // Leave Tracker
          if (leaves.isNotEmpty) ...[
            const SizedBox(height: AppUi.itemGap),
            const AppSectionTitle('LEAVE TRACKER'),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
              ),
              itemCount: leaves.length,
              itemBuilder: (_, i) => LeaveCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LeavePage(initialUserId: leaves[i].userId),
                  ),
                ),
                userId: leaves[i].userId,
                userName: leaves[i].userName,
                used: leaves[i].used,
                total: leaves[i].total,
                currentUserId: currentUserId,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFlowTransactions(BuildContext context, _FlowSheetType type) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.62,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) => _FlowTransactionsSheet(
          selectedMonth: selectedMonth,
          type: type,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

enum _FlowSheetType { inflow, outflow }

class _FlowTransactionsSheet extends ConsumerWidget {
  const _FlowTransactionsSheet({
    required this.selectedMonth,
    required this.type,
    required this.scrollController,
  });

  final DateTime selectedMonth;
  final _FlowSheetType type;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final txAsync = ref.watch(monthlyFlowTransactionsProvider(selectedMonth));
    final isInflowSheet = type == _FlowSheetType.inflow;
    final accentColor = isInflowSheet ? AppTheme.positive : AppTheme.negative;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isInflowSheet
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      size: 16,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isInflowSheet ? 'Monthly Inflows' : 'Monthly Outflows',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMMM yyyy').format(selectedMonth),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.labelMedium?.color,
                ),
              ),
              const SizedBox(height: 12),
              txAsync.when(
                data: (transactions) {
                  final filtered = transactions.where((tx) {
                    if (isInflowSheet) {
                      return tx.type == 'deposit';
                    }
                    return tx.type == 'borrow' || tx.type == 'pool_expense';
                  }).toList();
                  final total = filtered.fold<double>(
                    0,
                    (sum, tx) => sum + tx.amount,
                  );

                  return _FlowTotalSummary(
                    amount: total,
                    isInflowSheet: isInflowSheet,
                    accentColor: accentColor,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: txAsync.when(
                  data: (transactions) {
                    final filtered = transactions.where((tx) {
                      if (isInflowSheet) {
                        return tx.type == 'deposit';
                      }
                      return tx.type == 'borrow' || tx.type == 'pool_expense';
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 34,
                                color: theme.textTheme.labelMedium?.color,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isInflowSheet
                                    ? 'No inflow transactions in this month.'
                                    : 'No outflow transactions in this month.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.labelMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final groupedEntries = <_FlowListEntry>[];
                    DateTime? currentDate;
                    for (final tx in filtered) {
                      final txDate = DateTime(
                        tx.date.year,
                        tx.date.month,
                        tx.date.day,
                      );
                      if (currentDate == null || txDate != currentDate) {
                        groupedEntries.add(_FlowDateEntry(date: txDate));
                        currentDate = txDate;
                      }
                      groupedEntries.add(
                        _FlowTransactionEntry(transaction: tx),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: groupedEntries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = groupedEntries[index];
                        if (entry is _FlowDateEntry) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 2),
                            child: Text(
                              _formatFlowDateHeader(entry.date),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.textTheme.labelMedium?.color,
                              ),
                            ),
                          );
                        }

                        final tx = (entry as _FlowTransactionEntry).transaction;
                        final isInflow = tx.type == 'deposit';
                        final color = isInflow
                            ? AppTheme.positive
                            : AppTheme.negative;
                        final typeLabel = tx.type == 'borrow'
                            ? 'Borrowed from pool'
                            : tx.type == 'pool_expense'
                            ? 'Pool expense'
                            : 'Deposit';
                        final title =
                            (tx.description?.trim().isNotEmpty ?? false)
                            ? tx.description!.trim()
                            : typeLabel;

                        return AppCardSurface(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isInflow
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  size: 18,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${DateFormat('d MMM yyyy').format(tx.date)} • $typeLabel',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .labelMedium
                                                ?.color,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${isInflow ? '+' : '-'}SGD ${tx.amount.toStringAsFixed(2)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Failed to load transactions: $e',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFlowDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('EEE, d MMM').format(date);
  }
}

class _FlowTotalSummary extends StatelessWidget {
  const _FlowTotalSummary({
    required this.amount,
    required this.isInflowSheet,
    required this.accentColor,
  });

  final double amount;
  final bool isInflowSheet;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCardSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isInflowSheet ? 'Total Inflow' : 'Total Outflow',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.labelMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${isInflowSheet ? '+' : '-'}SGD ${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

sealed class _FlowListEntry {
  const _FlowListEntry();
}

class _FlowDateEntry extends _FlowListEntry {
  const _FlowDateEntry({required this.date});
  final DateTime date;
}

class _FlowTransactionEntry extends _FlowListEntry {
  const _FlowTransactionEntry({required this.transaction});
  final MonthlyFlowTransaction transaction;
}
