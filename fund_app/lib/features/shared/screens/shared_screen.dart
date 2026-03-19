import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fund_app/core/theme/app_theme.dart';
import 'package:fund_app/core/models/transaction_model.dart';

class SharedScreen extends ConsumerStatefulWidget {
  const SharedScreen({super.key});

  @override
  ConsumerState<SharedScreen> createState() => _SharedScreenState();
}

class _SharedScreenState extends ConsumerState<SharedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Expenses'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shared Expenses',
                style: AppTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacing16),
              // TODO: Connect to riverpod provider for shared expense transactions
              _buildSharedExpenseList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharedExpenseList() {
    // Placeholder - will be replaced with real data from provider
    final sharedExpenses = <Transaction>[];

    if (sharedExpenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing32),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'No shared expenses yet',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Add your first shared expense to get started',
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: sharedExpenses.map((transaction) {
        return _buildTransactionTile(transaction);
      }).toList(),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
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
                      style: AppTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      'Paid by: ${transaction.paidBy}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.date.toString().split(' ')[0],
                style: AppTheme.bodySmall,
              ),
              if (transaction.splitType == SplitType.equal)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    'Split Equal',
                    style: AppTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
