import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/constants/app_constants.dart';

/// Home Screen - Monthly Financial Overview
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final poolBalance = ref.watch(poolBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Please sign in'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pool Balance Card
                _buildPoolBalanceCard(context, poolBalance),
                const SizedBox(height: AppTheme.spacingL),
                // Monthly Summary
                _buildMonthlySummary(context, ref, user.id),
                const SizedBox(height: AppTheme.spacingL),
                // Money Owed Section
                _buildMoneyOwedSection(context, ref, user.id),
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

  Widget _buildPoolBalanceCard(
    BuildContext context,
    AsyncValue<double> poolBalance,
  ) {
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
            poolBalance.when(
              data: (balance) => Text(
                '\$${balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: balance >= 0 ? AppTheme.successColor : AppTheme.errorDark,
                    ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final now = DateTime.now();
    final monthlySummary = ref.watch(
      monthlySummaryProvider(
        (userIds: [userId], month: now),
      ),
    );

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
            monthlySummary.when(
              data: (summary) => Column(
                children: [
                  _buildSummaryRow(
                    context,
                    AppStrings.monthlyInflow,
                    '+\$${summary.inflow.toStringAsFixed(2)}',
                    AppTheme.successColor,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  _buildSummaryRow(
                    context,
                    AppStrings.monthlyOutflow,
                    '-\$${summary.outflow.toStringAsFixed(2)}',
                    AppTheme.errorDark,
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => Text('Error: $error'),
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

  Widget _buildMoneyOwedSection(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final userDebt = ref.watch(userDebtProvider(userId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.moneyOwedToPool,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            userDebt.when(
              data: (debt) => Text(
                '\$${debt.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: debt > 0 ? AppTheme.warningColor : AppTheme.successColor,
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
