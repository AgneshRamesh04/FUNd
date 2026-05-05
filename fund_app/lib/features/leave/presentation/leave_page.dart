import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_user.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/username_utils.dart';
import '../../../shared/providers/all_pool_members_provider.dart';
import '../../../shared/providers/current_user_provider.dart';
import '../data/leave_models.dart';
import '../data/leave_providers.dart';
import 'add_leave_entry_page.dart';

class LeavePage extends ConsumerStatefulWidget {
  const LeavePage({super.key, this.initialUserId});

  final String? initialUserId;

  @override
  ConsumerState<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends ConsumerState<LeavePage>
    with SingleTickerProviderStateMixin {
  late int _selectedYear;
  TabController? _tabController;
  List<AppUser> _users = const [];

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final membersAsync = ref.watch(allPoolMembersProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            _buildYearSelector(context),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: membersAsync.when(
          data: (members) {
            _users = members.take(2).toList();
            if (_users.isEmpty) {
              return const Center(child: Text('No users found'));
            }
            _ensureTabController();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: _buildProfessionalTabs(context, currentUserAsync),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _users.map((u) => _buildUserTab(context, u)).toList(),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  void _ensureTabController() {
    final targetLength = _users.length;
    if (_tabController != null && _tabController!.length == targetLength) {
      return;
    }

    _tabController?.dispose();

    var initialIndex = 0;
    final wantedUserId = widget.initialUserId;
    if (wantedUserId != null) {
      final idx = _users.indexWhere((u) => u.id == wantedUserId);
      if (idx >= 0) {
        initialIndex = idx;
      }
    }

    _tabController = TabController(
      length: targetLength,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final pickedYear = await showDialog<int>(
          context: context,
          builder: (dialogContext) {
            var tempYear = _selectedYear;
            return AlertDialog(
              title: const Text('Select year'),
              content: SizedBox(
                width: 300,
                height: 280,
                child: YearPicker(
                  firstDate: DateTime(2020),
                  lastDate: DateTime(DateTime.now().year + 5),
                  selectedDate: DateTime(_selectedYear),
                  onChanged: (value) {
                    tempYear = value.year;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(tempYear),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );

        if (pickedYear != null) {
          setState(() => _selectedYear = pickedYear);
        }
      },
      icon: const Icon(Icons.calendar_month_rounded, size: 16),
      label: Text('$_selectedYear'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildProfessionalTabs(BuildContext context, AsyncValue currentUserAsync) {
    final labels = _users.map((u) {
      return currentUserAsync.maybeWhen(
        data: (currentUser) => getDisplayName(
          u.id,
          currentUser.id,
          {u.id: u.name},
        ),
        orElse: () => u.name,
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.all(6),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.accent,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        tabs: labels.map((name) => Tab(text: name)).toList(),
      ),
    );
  }

  Widget _buildUserTab(BuildContext context, AppUser user) {
    final leaveTrackingAsync = ref.watch(
      leaveTrackingProvider((user.id, _selectedYear)),
    );
    final leaveEntriesState = ref.watch(
      leaveEntriesByYearProvider((user.id, _selectedYear)),
    );

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(leaveEntriesByYearProvider((user.id, _selectedYear)).notifier)
            .refresh();
        ref.invalidate(leaveTrackingProvider((user.id, _selectedYear)));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          leaveTrackingAsync.maybeWhen(
            data: (tracking) => tracking == null
                ? const SizedBox.shrink()
                : _buildLeaveBalanceCard(context, tracking),
            loading: () => const _ShimmerCard(),
            error: (e, _) => Text('Error: $e'),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => AddLeaveEntryPage(
                      userId: user.id,
                      year: _selectedYear,
                    ),
                  ),
                )
                .then((_) {
                  ref.invalidate(leaveTrackingProvider((user.id, _selectedYear)));
                  ref.invalidate(leaveEntriesByYearProvider((user.id, _selectedYear)));
                }),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Leave Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Entries',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          if (leaveEntriesState.isLoading)
            const _ShimmerList()
          else if (leaveEntriesState.error != null)
            Text('Error: ${leaveEntriesState.error}')
          else if (leaveEntriesState.entries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No leave entries for $_selectedYear',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...leaveEntriesState.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) => _deleteEntry(userId: user.id, entry: entry),
                  child: _buildLeaveEntryCard(context, entry),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Swipe left on an entry to delete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    letterSpacing: 0.4,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry({
    required String userId,
    required LeaveEntry entry,
  }) async {
    try {
      await ref
          .read(leaveEntriesByYearProvider((userId, _selectedYear)).notifier)
          .deleteEntry(entry.id);
      ref.invalidate(leaveTrackingProvider((userId, _selectedYear)));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave entry deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  Widget _buildLeaveBalanceCard(BuildContext context, LeaveTracking tracking) {
    final theme = Theme.of(context);
    final utilizationPercent = tracking.remaining > 0
        ? (tracking.used / tracking.total) * 100
        : 100;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withValues(alpha: 0.15),
            AppTheme.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Year ${tracking.year}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Leave Balance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '${tracking.remaining} left',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tracking.remaining > 0 ? AppTheme.accent : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: tracking.total > 0 ? utilizationPercent / 100 : 0,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(
                tracking.isExhausted ? Colors.red : AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, 'Used', '${tracking.used}', Colors.orange),
              _buildStatItem(
                context,
                'Total',
                '${tracking.total}',
                AppTheme.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveEntryCard(BuildContext context, LeaveEntry entry) {
    final theme = Theme.of(context);
    final tripIcon =
        entry.tripId != null ? Icons.luggage_rounded : Icons.calendar_today_rounded;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.8),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              tripIcon,
              size: 16,
              color: AppTheme.accent,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(entry.leaveDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
                '${entry.daysUsed}d',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      height: 170,
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            height: 88,
          ),
        ),
      ),
    );
  }
}
