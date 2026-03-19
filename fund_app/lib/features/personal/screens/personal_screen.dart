import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fund_app/core/theme/app_theme.dart';
import 'package:fund_app/core/models/transaction_model.dart';

class PersonalScreen extends ConsumerStatefulWidget {
  const PersonalScreen({super.key});

  @override
  ConsumerState<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends ConsumerState<PersonalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal - Borrows'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Borrowed Money',
                style: AppTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacing16),
              // TODO: Connect to riverpod provider for borrow transactions
              _buildBorrowTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBorrowTransactionList() {
    // Placeholder - will be replaced with real data from provider
    final borrowTransactions = <Transaction>[];

    if (borrowTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing32),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'No borrows yet',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Borrow money from the pool to get started',
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: borrowTransactions.map((transaction) {
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
      child: Row(
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
                  transaction.date.toString().split(' ')[0],
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
              if (transaction.notes != null)
                Text(
                  'Note: ${transaction.notes}',
                  style: AppTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
