import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final poolBalance = ref.watch(poolBalanceProvider).value ?? 0.0;
    final debts = ref.watch(userDebtsProvider).value ?? [];
    final leaves =
        ref.watch(userLeavesProvider(selectedMonth.year)).value ?? [];
    final inflowOutflow =
        ref.watch(inflowOutflowProvider(selectedMonth)).value ??
            {'inflow': 0.0, 'outflow': 0.0};

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PoolBalanceCard(balance: poolBalance),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InflowOutflowCard(
                  title: 'INFLOW',
                  amount: inflowOutflow['inflow'] ?? 0.0,
                  positive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InflowOutflowCard(
                  title: 'OUTFLOW',
                  amount: inflowOutflow['outflow'] ?? 0.0,
                  positive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DebtCard(
            debts: debts
                .map((d) => Debt(userName: d.userName, amount: d.amount))
                .toList(),
          ),
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
                userName: leaves[i].userName,
                used: leaves[i].used,
                total: leaves[i].total,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
