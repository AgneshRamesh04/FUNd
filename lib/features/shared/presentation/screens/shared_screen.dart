import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../transactions/presentation/providers/transaction_providers.dart';
import '../../transactions/domain/entities/transaction_entity.dart';

/// Shared Screen - Shared Expenses (Clean Architecture)
class SharedScreenClean extends ConsumerWidget {
  const SharedScreenClean({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Get actual user ID
    const userId = 'user-1';
    final sharedExpenses = ref.watch(userSharedExpensesProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.sharedTitle),
      ),
      body: sharedExpenses.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: AppTheme.textColorTertiary,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    AppStrings.noSharedExpenses,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textColorTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final transaction = expenses[index];
              return _buildExpenseCard(context, transaction, userId);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(
    BuildContext context,
    TransactionEntity transaction,
    String userId,
  ) {
    final userShare = _calculateUserShare(transaction, userId);
    final isPaidByCurrentUser = transaction.paidBy == userId;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        'Paid by ${transaction.paidBy}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${transaction.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Your share: \$${userShare.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isPaidByCurrentUser
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              transaction.date.toString().split(' ')[0],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textColorTertiary,
              ),
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.spacingM),
                child: Text(
                  transaction.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textColorSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateUserShare(TransactionEntity transaction, String userId) {
    if (transaction.splitType == SplitType.equal) {
      return transaction.amount / 2;
    } else if (transaction.splitType == SplitType.custom &&
        transaction.splitData != null) {
      return transaction.splitData![userId] as double? ?? 0;
    }
    return 0;
  }
}
