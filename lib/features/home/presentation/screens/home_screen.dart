import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/transaction_providers.dart';

/// Home Screen - Monthly Financial Overview (Clean Architecture)
class HomeScreenClean extends ConsumerWidget {
  const HomeScreenClean({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolBalance = ref.watch(poolBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
      ),
      body: poolBalance.when(
        data: (balance) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPoolBalanceCard(context, balance),
                const SizedBox(height: AppTheme.spacingL),
                _buildMonthlySummarySection(context),
                const SizedBox(height: AppTheme.spacingL),
                _buildRecentTransactionsSection(context, ref),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildPoolBalanceCard(BuildContext context, double balance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.poolBalance,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: balance >= 0
                        ? AppTheme.successColor
                        : AppTheme.errorDark,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummarySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildSummaryRow(
              context,
              AppStrings.monthlyInflow,
              '+\$500.00',
              AppTheme.successColor,
            ),
            const SizedBox(height: AppTheme.spacingS),
            _buildSummaryRow(
              context,
              AppStrings.monthlyOutflow,
              '-\$250.00',
              AppTheme.errorDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String amount,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(
    BuildContext context,
    WidgetRef ref,
  ) {
    final transactions = ref.watch(transactionsProvider);

    return transactions.when(
      data: (txns) {
        final recent = txns.take(5).toList();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingM),
                if (recent.isEmpty)
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    itemBuilder: (context, index) {
                      final txn = recent[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingS,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                txn.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              '\$${txn.amount.toStringAsFixed(2)}',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }
}
