import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Haptics
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Modern Animated App Bar ────────────────────────────────
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                trip.tripName ?? 'Trip Details',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16),
            ),
          ),

          // ── Content Area ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _TripInfoCard(trip: trip, theme: theme),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRIP EXPENSES',
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: theme.hintColor,
                      ),
                    ),
                    if (tripExpensesAsync.value?.isNotEmpty ?? false)
                      Text(
                        '${tripExpensesAsync.value!.length} items',
                        style: theme.textTheme.labelSmall,
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                tripExpensesAsync.when(
                  data: (expenses) {
                    if (expenses.isEmpty) {
                      return const TransactionEmptyState();
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
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
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Failed to load: $e', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleCreateExpense(context, ref),
        label: const Text('Add Expense'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // --- Handlers remain structurally the same but with UX feedback ---

  Future<void> _handleCreateExpense(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
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
  }

  Future<void> _handleDeleteExpense(
    BuildContext context,
    WidgetRef ref,
    TripExpense expense,
  ) async {
    // HapticFeedback.warningImpact();
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Expense?'),
        content: const Text('This will permanently remove this item from your trip records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
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
          SnackBar(
            content: const Text('Expense deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
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
    final totalStr = NumberFormat.currency(symbol: 'SGD ', decimalDigits: 2)
        .format(trip.totalExpense ?? 0);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusBadge(trip: trip),
                Text(
                  '${trip.durationDays ?? 0} days duration',
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              totalStr,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppTheme.negative,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'TOTAL TRIP EXPENDITURE',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 0.8,
                color: theme.hintColor,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, thickness: 0.5),
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _DetailItem(
                      label: 'Departure',
                      value: startStr,
                      icon: Icons.flight_takeoff_rounded,
                      theme: theme,
                    ),
                  ),
                  VerticalDivider(
                    width: 32,
                    thickness: 1,
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                  Expanded(
                    child: _DetailItem(
                      label: 'Return',
                      value: endStr,
                      icon: Icons.flight_land_rounded,
                      theme: theme,
                    ),
                  ),
                ],
              ),
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
    final (label, color) = switch (trip.status) {
      TripStatus.ongoing => ('Ongoing', AppTheme.positive),
      TripStatus.upcoming => ('Upcoming', AppTheme.accent),
      TripStatus.past => ('Past', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
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
            Icon(icon, size: 14, color: theme.hintColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}