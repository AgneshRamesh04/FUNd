import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/ui/app_ui.dart';

class PoolBalanceCard extends StatelessWidget {
  final double balance;

  const PoolBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 14, color: AppTheme.accent),
              ),
              const SizedBox(width: 8),
              Text('FUNd BALANCE', style: theme.textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'SGD',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          Text(
            balance.toStringAsFixed(2),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
