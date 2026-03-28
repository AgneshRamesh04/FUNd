import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class InflowOutflowCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool positive;

  const InflowOutflowCard({
    super.key,
    required this.title,
    required this.amount,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = positive ? AppTheme.positive : AppTheme.negative;
    final bgColor = color.withValues(alpha: 0.08);
    final iconData =
        positive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'SGD',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          Text(
            amount.toStringAsFixed(2),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
