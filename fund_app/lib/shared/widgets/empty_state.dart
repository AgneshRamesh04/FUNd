import 'package:flutter/material.dart';

/// Enhanced empty state with icon, title, and optional action
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: theme.primaryColor.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.labelMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state for transactions
class TransactionEmptyState extends StatelessWidget {
  final VoidCallback? onAddTransaction;

  const TransactionEmptyState({super.key, this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox_rounded,
      title: 'No transactions',
      subtitle: 'Start by adding a transaction to get started',
      onAction: onAddTransaction,
      actionLabel: onAddTransaction != null ? 'Add Transaction' : null,
    );
  }
}

/// Empty state for debts
class DebtEmptyState extends StatelessWidget {
  const DebtEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.done_all_rounded,
      title: 'All settled up',
      subtitle: 'No outstanding debts between users',
    );
  }
}

/// Error state
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Something went wrong',
      subtitle: message,
      onAction: onRetry,
      actionLabel: onRetry != null ? 'Retry' : null,
    );
  }
}
