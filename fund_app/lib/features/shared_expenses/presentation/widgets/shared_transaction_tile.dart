import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/shared_expenses_models.dart';

({String label, IconData icon, Color color, String sign}) _meta(String type) =>
    switch (type) {
      'user_paid_for_pool' => (
        label: 'Contribution',
        icon: Icons.account_balance_wallet_rounded,
        color: AppTheme.positive,
        sign: '+',
      ),
      'pool_expense' => (
        label: 'Pool Expense',
        icon: Icons.receipt_long_rounded,
        color: AppTheme.negative,
        sign: '-',
      ),
      _ => (
        label: type,
        icon: Icons.payment_rounded,
        color: Colors.grey,
        sign: '',
      ),
    };

class SharedTransactionTile extends StatelessWidget {
  final SharedTransaction tx;
  final String userName;
  final bool showDivider;

  const SharedTransactionTile({
    super.key,
    required this.tx,
    required this.userName,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = _meta(tx.type);
    final amountStr =
        '${m.sign}SGD ${NumberFormat('#,##0.00').format(tx.amount)}';

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
