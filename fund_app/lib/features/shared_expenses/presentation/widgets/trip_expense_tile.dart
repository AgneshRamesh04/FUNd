import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/shared_expenses_models.dart';

({String label, IconData icon, Color color}) _meta(String type) =>
    switch (type) {
      'user_paid_for_pool' => (
        label: 'Lend',
        icon: Icons.account_balance_wallet_rounded,
        color: AppTheme.positive,
      ),
      'pool_expense' => (
        label: 'FUNd Expense',
        icon: Icons.receipt_long_rounded,
        color: AppTheme.negative,
      ),
      _ => (label: type, icon: Icons.payment_rounded, color: Colors.grey),
    };

class TripExpenseTile extends StatelessWidget {
  final TripExpense expense;
  final String userName;
  final bool showDivider;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TripExpenseTile({
    super.key,
    required this.expense,
    required this.userName,
    this.showDivider = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = _meta(expense.type);
    final amountStr = 'SGD ${NumberFormat('#,##0.00').format(expense.amount)}';

    return Dismissible(
      key: Key(expense.id),
      // --- SWIPE RIGHT (EDIT) ---
      background: Container(
        color: Colors.blue.shade600,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_rounded, color: Colors.white),
            SizedBox(height: 4),
            Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // --- SWIPE LEFT (DELETE) ---
      secondaryBackground: Container(
        color: AppTheme.negative,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.white),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false;
        } else {
          onDelete?.call();
          return false;
        }
      },
      child: InkWell(
        onTap: onEdit,
        child: Container(
          decoration: BoxDecoration(color: theme.cardColor),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  children: [
                    // Icon Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(m.icon, color: m.color, size: 20),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.label} • ${DateFormat('MMM d').format(expense.date)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if ((expense.description ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              expense.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Amount & Date Column
                    Text(
                      amountStr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: m.color,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (showDivider)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 76,
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
