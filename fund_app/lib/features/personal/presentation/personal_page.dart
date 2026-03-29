import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/username_utils.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

import '../../home/data/home_providers.dart';
import '../../../shared/providers/current_user_provider.dart';
import '../data/personal_providers.dart';
import 'widgets/transaction_tile.dart';

class PersonalPage extends ConsumerWidget {
  const PersonalPage({super.key, required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final debts = ref.watch(userDebtsProvider).value ?? [];
    // Generate month key in YYYY-MM format
    final monthKey = '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}';
    final txState = ref.watch(personalTransactionsProvider(monthKey));
    final userNames = ref.watch(personalUserNamesProvider).value ?? {};
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
          // ── Total owed to FUNd ────────────────────────────────────────────
          Text('TOTAL OWED TO FUNd', style: theme.textTheme.labelMedium),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerTheme.color ?? Colors.transparent,
              ),
            ),
            child: Builder(
              builder: (context) {
                if (debts.isEmpty) {
                  return Text(
                    'No debts',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.labelMedium?.color,
                    ),
                  );
                }
                
                final totalDebt = debts.fold<double>(0, (sum, d) => sum + d.amount);
                final fmt = NumberFormat('#,##0.00');
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SGD ${fmt.format(totalDebt)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(debts.length, (i) {
                      final d = debts[i];
                      final isLast = i == debts.length - 1;
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getDisplayName(d.userId, currentUserId, userNames),
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                'SGD ${fmt.format(d.amount)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          if (!isLast) ...[
                            const SizedBox(height: 12),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: theme.dividerTheme.color,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // ── Transactions ──────────────────────────────────────────────
          Text('PERSONAL TRANSACTIONS', style: theme.textTheme.labelMedium),
          const SizedBox(height: 12),
          Builder(
            builder: (_) {
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
                    return TransactionTile(
                      tx: txState.transactions[i],
                      userName: getDisplayName(
                        txState.transactions[i].userId,
                        currentUserId,
                        userNames,
                      ),
                      showDivider: i < txState.transactions.length - 1,
                    );
                  }),
                ),
              );
            },
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
          Icon(
            Icons.receipt_long_outlined,
            size: 36,
            color: theme.textTheme.labelMedium?.color,
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.labelMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
