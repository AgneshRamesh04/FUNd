import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fund_app/core/utils/date_utils.dart' as app_date;
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/username_utils.dart';
import '../../../shared/ui/app_feedback.dart';
import '../../../shared/ui/app_ui.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

import '../../home/data/home_providers.dart';
import '../../../shared/providers/current_user_provider.dart';
import '../../transactions/data/transaction_service.dart';
import '../../transactions/presentation/transaction_form_page.dart';
import '../../shell/shell_page.dart';
import '../data/personal_models.dart';
import '../data/personal_providers.dart';
import 'widgets/transaction_tile.dart';

class PersonalPage extends ConsumerWidget {
  const PersonalPage({super.key, required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final debts = ref.watch(userDebtsProvider).value ?? [];
    // Generate month key in YYYY-MM format for backend query
    // DateUtils.toMonthKey returns 'YYYY-MM-01'
    // We want 'YYYY-MM'
    final monthKey = app_date.DateUtils.toMonthKey(
      selectedMonth,
    ).substring(0, 7);
    final txState = ref.watch(personalTransactionsProvider(monthKey));
    final userNames = ref.watch(personalUserNamesProvider).value ?? {};
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
          // ── Total owed to FUNd ────────────────────────────────────────────
          const AppSectionTitle('TOTAL OWED TO FUNd'),
          const SizedBox(height: 10),
          AppCardSurface(
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

                final totalDebt = debts.fold<double>(
                  0,
                  (sum, d) => sum + d.amount,
                );
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
                                getDisplayName(
                                  d.userId,
                                  currentUserId,
                                  userNames,
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                'SGD ${fmt.format(d.amount)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
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
          const SizedBox(height: AppUi.sectionGap),

          // ── Transactions ──────────────────────────────────────────────
          const AppSectionTitle('PERSONAL TRANSACTIONS'),
          const SizedBox(height: AppUi.compactGap),
          Builder(
            builder: (_) {
              late final Widget content;
              if (txState.isLoading) {
                content = const TransactionListSkeleton();
              } else if (txState.error != null) {
                content = ErrorState(
                  message: txState.error ?? 'Failed to load transactions',
                );
              } else if (txState.transactions.isEmpty) {
                content = const TransactionEmptyState();
              } else {
                // Transactions are already filtered by the provider (backend query)
                content = AppCardSurface(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: List.generate(txState.transactions.length, (i) {
                      final tx = txState.transactions[i];
                      return TransactionTile(
                        tx: tx,
                        userName: getDisplayName(
                          tx.userId,
                          currentUserId,
                          userNames,
                        ),
                        showDivider: i < txState.transactions.length - 1,
                        onEdit: () => _editPersonalTransaction(context, tx),
                        onDelete: () =>
                            _confirmDeletePersonalTransaction(context, ref, tx),
                      );
                    }),
                  ),
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: KeyedSubtree(
                  key: ValueKey(
                    '${txState.isLoading}-${txState.error}-${txState.transactions.length}',
                  ),
                  child: content,
                ),
              );
            },
          ),
          const SizedBox(height: AppUi.compactGap),
          Text(
            'Swipe right to edit, left to delete.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.labelMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _editPersonalTransaction(BuildContext context, PersonalTransaction tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionFormPage(
          args: TransactionFormArgs(
            type: tx.type,
            initialMonth: tx.date,
            editingTransaction: tx,
            isEditing: true,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeletePersonalTransaction(
    BuildContext context,
    WidgetRef ref,
    PersonalTransaction tx,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirm delete'),
          content: const Text(
            'Delete this transaction? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.negative),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(transactionServiceProvider)
          .deletePersonalTransaction(tx.id);
      if (!context.mounted) return;
      AppFeedback.showSuccess(context, 'Personal transaction deleted');
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(context, 'Delete failed: ${e.toString()}');
      }
    }
  }
}
