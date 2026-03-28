import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/home_models.dart';

class DebtCard extends StatelessWidget {
  final List<Debt> debts;

  const DebtCard({super.key, required this.debts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MEMBER DEBTS', style: theme.textTheme.labelMedium),
          const SizedBox(height: 16),
          if (debts.isEmpty)
            Text('All settled up',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.textTheme.labelMedium?.color))
          else
            ...List.generate(debts.length, (i) {
              final d = debts[i];
              final color =
                  d.amount >= 0 ? AppTheme.negative : AppTheme.positive;
              return Column(
                children: [
                  Row(
                    children: [
                      // Avatar initial
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          d.userName.isNotEmpty
                              ? d.userName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(d.userName,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${d.amount >= 0 ? '+' : ''}SGD ${d.amount.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          Text(
                            d.amount >= 0 ? 'owes' : 'owed',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (i < debts.length - 1)
                    Divider(
                      height: 24,
                      color: theme.dividerTheme.color,
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}
