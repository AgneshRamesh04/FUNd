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
    final amountStr =
        'SGD ${NumberFormat('#,##0.00').format(tx.amount)}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(m.icon, color: m.color, size: 18),
              ),
              const SizedBox(width: 12),
              // Name + type + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${m.label}  ·  ${DateFormat('MMM d, y').format(tx.date)}',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.textTheme.labelMedium?.color),
                    ),
                    if ((tx.description?.isNotEmpty ?? false) ||
                        (tx.notes?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 4),
                      Text(
                        tx.description?.isNotEmpty == true
                            ? tx.description!
                            : tx.notes!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.labelMedium?.color,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount
              Text(
                amountStr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: m.color,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerTheme.color,
          ),
      ],
    );
  }
}
