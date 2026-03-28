import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/personal_models.dart';

({String label, IconData icon, Color color, String sign}) _meta(String type) =>
    switch (type) {
      'deposit' => (
        label: 'Deposit',
        icon: Icons.savings_rounded,
        color: AppTheme.positive,
        sign: '+',
      ),
      'borrow' => (
        label: 'Borrow',
        icon: Icons.north_east_rounded,
        color: AppTheme.negative,
        sign: '-',
      ),
      'monthly_obligation' => (
        label: 'Obligation',
        icon: Icons.repeat_rounded,
        color: AppTheme.warning,
        sign: '',
      ),
      _ => (
        label: type,
        icon: Icons.payment_rounded,
        color: Colors.grey,
        sign: '',
      ),
    };

class TransactionTile extends StatelessWidget {
  final PersonalTransaction tx;
  final String userName;
  final bool showDivider;

  const TransactionTile({
    super.key,
    required this.tx,
    required this.userName,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = _meta(tx.type);

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
                    Row(
                      children: [
                        Text(m.label, style: theme.textTheme.labelSmall),
                        Text(' · ', style: theme.textTheme.labelSmall),
                        Text(
                          DateFormat('d MMM').format(tx.date),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                    if ((tx.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        tx.description!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else if ((tx.notes ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        tx.notes!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount
              Text(
                '${m.sign}SGD ${tx.amount.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: m.color,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: theme.dividerTheme.color),
      ],
    );
  }
}
