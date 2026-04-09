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
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
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
                            userName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.label} • ${DateFormat('d MMM').format(tx.date)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if ((tx.description ?? '').isNotEmpty || (tx.notes ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              (tx.description?.isNotEmpty == true) ? tx.description! : tx.notes!,
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
                    // Amount
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