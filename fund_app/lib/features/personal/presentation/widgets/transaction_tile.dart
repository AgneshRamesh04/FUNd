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
        color: const Color(0xFF9CA3AF),
        sign: '',
      ),
    };

class TransactionTile extends StatelessWidget {
  final PersonalTransaction tx;
  final String userName;
  final bool showDivider;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
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
    final amountStr = '${m.sign}SGD ${tx.amount.toStringAsFixed(2)}';
    final primaryText = (tx.description?.trim().isNotEmpty ?? false)
        ? tx.description!.trim()
        : ((tx.notes?.trim().isNotEmpty ?? false)
              ? tx.notes!.trim()
              : m.label);

    return Dismissible(
      key: Key(tx.id.toString()),
      // Swipe Right -> Edit (Blue)
      background: Container(
        color: Colors.blue.shade700,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      // Swipe Left -> Delete (Red)
      secondaryBackground: Container(
        color: AppTheme.negative,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false; // Keep the tile in the list
        } else {
          onDelete?.call();
          return false; // Keep the tile (let the parent handle removal)
        }
      },
      child: Material(
        color: theme.cardColor, // Direct background color prevents gaps
        child: InkWell(
          onTap: onEdit,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Modern Circular Icon Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(m.icon, color: m.color, size: 20),
                    ),
                    const SizedBox(width: 16),
                    // Transaction Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            primaryText,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d MMM').format(tx.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$userName • ${m.label}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Amount
                    Flexible(
                      flex: 0,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          amountStr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: m.color,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showDivider)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 76, // Aligned with the text start
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
