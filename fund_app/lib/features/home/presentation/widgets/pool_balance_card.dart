import 'package:flutter/material.dart';

class PoolBalanceCard extends StatelessWidget {
  final double balance;

  const PoolBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FUNd BALANCE', style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            Text(
              'SGD ${balance.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
