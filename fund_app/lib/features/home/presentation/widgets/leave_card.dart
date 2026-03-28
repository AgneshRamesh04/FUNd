import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/username_utils.dart';

class LeaveCard extends StatelessWidget {
  final String userId;
  final String userName;
  final int used;
  final int total;
  final String currentUserId;

  const LeaveCard({
    super.key,
    required this.userId,
    required this.userName,
    required this.used,
    required this.total,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final color = percent < 0.7 ? AppTheme.positive : AppTheme.warning;
    final remaining = total - used;

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Avatar + name row
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  getDisplayName(userId, currentUserId, {userId: userName})
                      .isNotEmpty
                      ? getDisplayName(userId, currentUserId, {userId: userName})[0]
                          .toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  getDisplayName(userId, currentUserId, {userId: userName}),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 5),
          // Used / remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$remaining left of $total',
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
