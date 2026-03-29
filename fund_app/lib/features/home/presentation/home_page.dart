import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/current_user_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../data/home_models.dart';
import '../data/home_providers.dart';
import 'widgets/debt_card.dart';
import 'widgets/inflow_outflow_card.dart';
import 'widgets/leave_card.dart';
import 'widgets/pool_balance_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final poolBalanceAsync = ref.watch(poolBalanceProvider);
    final debtsAsync = ref.watch(userDebtsProvider);
    final leaves =
        ref.watch(userLeavesProvider(selectedMonth.year)).value ?? [];
    final inflowOutflowAsync =
        ref.watch(inflowOutflowProvider(selectedMonth));
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
          // Pool Balance Card
          poolBalanceAsync.when(
            data: (balance) => PoolBalanceCard(balance: balance),
            loading: () => const CardSkeleton(),
            error: (e, st) => ErrorState(
              message: e.toString(),
            ),
          ),
          const SizedBox(height: 16),
          // Inflow/Outflow Cards
          Row(
            children: [
              Expanded(
                child: inflowOutflowAsync.when(
                  data: (inflowOutflow) => InflowOutflowCard(
                    title: 'INFLOW',
                    amount: inflowOutflow['inflow'] ?? 0.0,
                    positive: true,
                  ),
                  loading: () => const CardSkeleton(),
                  error: (e, st) => ErrorState(
                    message: e.toString(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: inflowOutflowAsync.when(
                  data: (inflowOutflow) => InflowOutflowCard(
                    title: 'OUTFLOW',
                    amount: inflowOutflow['outflow'] ?? 0.0,
                    positive: false,
                  ),
                  loading: () => const CardSkeleton(),
                  error: (e, st) => ErrorState(
                    message: e.toString(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Debt Card
          debtsAsync.when(
            data: (debts) => debts.isEmpty
                ? const DebtEmptyState()
                : DebtCard(
                    debts: debts
                        .map((d) => Debt(
                          userId: d.userId,
                          userName: d.userName,
                          amount: d.amount,
                        ))
                        .toList(),
                    currentUserId: currentUserId,
                  ),
            loading: () => const CardSkeleton(),
            error: (e, st) => ErrorState(
              message: e.toString(),
            ),
          ),
          // Leave Tracker
          if (leaves.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('LEAVE TRACKER', style: theme.textTheme.labelMedium),
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
}
