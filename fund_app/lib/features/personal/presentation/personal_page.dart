import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/data/home_models.dart';
import '../../home/data/home_providers.dart';
import '../data/personal_providers.dart';
import 'widgets/transaction_tile.dart';

class PersonalPage extends ConsumerWidget {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final debts = ref.watch(userDebtsProvider).value ?? [];
    final txState = ref.watch(personalTransactionsProvider);
    final userNames = ref.watch(personalUserNamesProvider).value ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Total owed to pool ────────────────────────────────────────────
          Text('TOTAL OWED TO POOL', style: theme.textTheme.labelMedium),
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
                                d.userName,
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
                return const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: LinearProgressIndicator(),
                );
              }
              if (txState.error != null) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${txState.error}',
                    style: const TextStyle(color: AppTheme.negative),
                  ),
                );
              }
              if (txState.transactions.isEmpty) return _EmptyState();

              // Group by month key, preserving newest-first order
              final Map<String, List> grouped = {};
              for (final tx in txState.transactions) {
                (grouped[tx.resolvedMonthKey] ??= []).add(tx);
              }
              final keys = grouped.keys.toList();

              return Column(
                children: [
                  ...keys.map((monthKey) {
                    final group = grouped[monthKey]!;
                    final label = _monthLabel(monthKey);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month group header
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
                                  label,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Transaction card for the group
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerTheme.color ??
                                  Colors.transparent,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: List.generate(group.length, (i) {
                              return TransactionTile(
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
                  // ── Load more footer ───────────────────────────────────
                  if (txState.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child:
                          Center(child: CircularProgressIndicator.adaptive()),
                    )
                  else if (txState.hasMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Center(
                        child: TextButton(
                          onPressed: () => ref
                              .read(personalTransactionsProvider.notifier)
                              .loadMore(),
                          child: Text(
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
            },
          ),
        ],
      ),
    );
  }

  /// Parses "2026-03" → "March 2026"
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
