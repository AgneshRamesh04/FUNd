import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/current_user_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../transactions/presentation/transaction_form_page.dart';
import '../../shell/shell_page.dart';
import '../data/shared_expenses_models.dart';
import '../data/shared_expenses_providers.dart';
import 'widgets/trip_expense_tile.dart';

class TripDetailsPage extends ConsumerWidget {
  final TripSummary trip;

  const TripDetailsPage({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripExpensesAsync = ref.watch(tripExpensesProvider(trip.tripId ?? ''));
    final userNames = ref.watch(sharedUserNamesProvider).value ?? {};
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.maybeWhen(
      data: (user) => user.id,
      orElse: () => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.tripName ?? 'Trip Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Trip Info Card ─────────────────────────────────────────
            _TripInfoCard(trip: trip, theme: theme),
            const SizedBox(height: 28),

            // ── Trip Expenses ──────────────────────────────────────────
            Text('TRIP EXPENSES', style: theme.textTheme.labelMedium),
            const SizedBox(height: 12),
            tripExpensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const TransactionEmptyState();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    final userName = userNames[expense.userId] ?? 'Unknown';
                    return TripExpenseTile(
                      expense: expense,
                      userName: userName,
                      showDivider: index < expenses.length - 1,
                      onEdit: () => _handleEditExpense(
                        context,
                        ref,
                        expense,
                        currentUserId,
                      ),
                      onDelete: () => _handleDeleteExpense(
                        context,
                        ref,
                        expense,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => ErrorState(
                message: 'Failed to load trip expenses: $e',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleCreateExpense(context, ref),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleCreateExpense(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormPage(
          args: TransactionFormArgs(
            type: 'trip_expense',
            initialMonth: DateTime.now(),
            isEditing: false,
            tripId: trip.tripId,
            tripName: trip.tripName,
          ),
        ),
      ),
    );
    // Real-time subscription is managed globally by RealtimeService
  }

  Future<void> _handleEditExpense(
    BuildContext context,
    WidgetRef ref,
    TripExpense expense,
    String currentUserId,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormPage(
          args: TransactionFormArgs(
            type: 'trip_expense',
            initialMonth: expense.date,
            editingTransaction: expense,
            isEditing: true,
            tripId: trip.tripId,
            tripName: trip.tripName,
          ),
        ),
      ),
    );
    // Real-time subscription is managed globally by RealtimeService
  }

  Future<void> _handleDeleteExpense(
    BuildContext context,
    WidgetRef ref,
    TripExpense expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !context.mounted) return;

    try {
      await ref
          .read(sharedExpensesRepositoryProvider)
          .deleteTripExpense(expense.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted')),
        );
        // Real-time subscription is managed globally by RealtimeService
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }
}

class _TripInfoCard extends StatelessWidget {
  final TripSummary trip;
  final ThemeData theme;

  const _TripInfoCard({
    required this.trip,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final startStr = trip.startDate != null
        ? DateFormat('MMM d, yyyy').format(trip.startDate!)
        : '-';
    final endStr = trip.endDate != null
        ? DateFormat('MMM d, yyyy').format(trip.endDate!)
        : '-';
    final totalStr = 'SGD ${NumberFormat('#,##0.00').format(trip.totalExpense ?? 0)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip name
            Text(
              trip.tripName ?? 'Unnamed Trip',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Status badge
            Row(
              children: [
                _StatusBadge(trip: trip),
              ],
            ),
            const SizedBox(height: 16),

            // Trip details grid
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Start Date',
                    value: startStr,
                    icon: Icons.calendar_today_rounded,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DetailItem(
                    label: 'End Date',
                    value: endStr,
                    icon: Icons.calendar_today_rounded,
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Duration',
                    value: '${trip.durationDays ?? 0} days',
                    icon: Icons.schedule_rounded,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DetailItem(
                    label: 'Total Expense',
                    value: totalStr,
                    icon: Icons.trending_down_rounded,
                    theme: theme,
                    valueColor: AppTheme.negative,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TripSummary trip;

  const _StatusBadge({required this.trip});

  @override
  Widget build(BuildContext context) {
    final statusInfo = switch (trip.status) {
      TripStatus.ongoing => (label: 'Ongoing', color: AppTheme.positive),
      TripStatus.upcoming => (label: 'Upcoming', color: AppTheme.accent),
      TripStatus.past => (label: 'Past', color: Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusInfo.label,
        style: TextStyle(
          color: statusInfo.color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.textTheme.labelSmall?.color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
