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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _FlowTransactionsSheet(selectedMonth: selectedMonth, type: type),
    );
  }
}

enum _FlowSheetType { inflow, outflow }

class _FlowTransactionsSheet extends ConsumerWidget {
  const _FlowTransactionsSheet({required this.selectedMonth, required this.type});

  final DateTime selectedMonth;
  final _FlowSheetType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final txAsync = ref.watch(monthlyFlowTransactionsProvider(selectedMonth));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == _FlowSheetType.inflow
                  ? 'Monthly Inflows'
                  : 'Monthly Outflows',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMMM yyyy').format(selectedMonth),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.labelMedium?.color,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.56,
              child: txAsync.when(
                data: (transactions) {
                  final filtered = transactions.where((tx) {
                    if (type == _FlowSheetType.inflow) {
                      return tx.type == 'deposit';
                    }
                    return tx.type == 'borrow' || tx.type == 'pool_expense';
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        type == _FlowSheetType.inflow
                            ? 'No inflow (deposit) transactions for this month.'
                            : 'No outflow (borrow/pool expense) transactions for this month.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.labelMedium?.color,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      final isInflow = tx.type == 'deposit';
                      final color = isInflow
                          ? AppTheme.positive
                          : AppTheme.negative;
                      final typeLabel = tx.type == 'borrow'
                          ? 'Borrow'
                          : tx.type == 'pool_expense'
                          ? 'Pool Expense'
                          : 'Deposit';
                      final title = (tx.description?.trim().isNotEmpty ?? false)
                          ? tx.description!.trim()
                          : (isInflow
                                ? 'Deposit transaction'
                                : 'Outflow transaction');

                      return AppCardSurface(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DateFormat('d MMM yyyy').format(tx.date)} • $typeLabel',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.labelMedium?.color,
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
    );
  }
}
