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
      _ => (
        label: type,
        icon: Icons.payment_rounded,
        color: Colors.grey,
      ),
    };

class SharedTransactionTile extends StatelessWidget {
  final SharedTransaction tx;
  final String userName;
  final bool showDivider;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SharedTransactionTile({
    super.key,
    required this.tx,
    required this.userName,
    this.showDivider = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = _meta(tx.type);
    final amountStr = 'SGD ${NumberFormat('#,##0.00').format(tx.amount)}';

    return Dismissible(
      key: Key(tx.id.toString()),
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
            Text('Edit', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
      child: InkWell( // Use InkWell for better material ripple effects
        onTap: onEdit,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  children: [
                    // Icon Badge with softer styling
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.08),
                        shape: BoxShape.circle, // Circular icons look more modern
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
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.label} • ${DateFormat('MMM d').format(tx.date)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (tx.description?.isNotEmpty == true || tx.notes?.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Text(
                              tx.description?.isNotEmpty == true ? tx.description! : tx.notes!,
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
                    // Amount with tabular figures for alignment
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amountStr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: m.color,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        // Small "Swipe" hint or status could go here
                      ],
                    ),
                  ],
                ),
              ),
              if (showDivider)
                Divider(
                  height: 1,
                  thickness: 0.5, // Thinner divider for a cleaner look
                  indent: 76,    // Aligns with the start of the text (44 icon + 16 gap + 16 padding)
                  endIndent: 0,
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}