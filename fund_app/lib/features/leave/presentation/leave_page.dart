import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_user.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/username_utils.dart';
import '../../../shared/providers/all_pool_members_provider.dart';
import '../../../shared/providers/current_user_provider.dart';
import '../../../shared/ui/app_feedback.dart';
import '../../../shared/ui/app_ui.dart';
import '../../shared_expenses/data/shared_expenses_providers.dart';
import '../data/leave_models.dart';
import '../data/leave_providers.dart';
import 'add_leave_entry_page.dart';
import 'manage_leave_totals_page.dart';

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
          children: [const SizedBox(width: 12), _buildYearSelector(context)],
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
                  padding: const EdgeInsets.fromLTRB(
                    AppUi.pageHorizontalPadding,
                    8,
                    AppUi.pageHorizontalPadding,
                    4,
                  ),
                  child: _buildProfessionalTabs(context, currentUserAsync),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _users
                        .map((u) => _buildUserTab(context, u))
                        .toList(),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: membersAsync.maybeWhen(
        data: (_) {
          final activeUser = _activeUser;
          if (activeUser == null) return null;
          return FloatingActionButton.extended(
            onPressed: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => AddLeaveEntryPage(
                      userId: activeUser.id,
                      year: _selectedYear,
                    ),
                  ),
                )
                .then((_) {
                  ref.invalidate(
                    leaveTrackingProvider((activeUser.id, _selectedYear)),
                  );
                  ref.invalidate(
                    leaveEntriesByYearProvider((activeUser.id, _selectedYear)),
                  );
                }),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Leave'),
          );
        },
        orElse: () => null,
      ),
    );
  }

  AppUser? get _activeUser {
    if (_users.isEmpty) return null;
    final index = _tabController?.index ?? 0;
    if (index < 0 || index >= _users.length) return _users.first;
    return _users[index];
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
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Select year'),
                  content: SizedBox(
                    width: 300,
                    height: 280,
                    child: YearPicker(
                      firstDate: DateTime(2020),
                      lastDate: DateTime(DateTime.now().year + 5),
                      selectedDate: DateTime(tempYear),
                      onChanged: (value) {
                        setDialogState(() {
                          tempYear = value.year;
                        });
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(dialogContext).pop(tempYear),
                      child: const Text('Apply'),
                    ),
                  ],
                );
              },
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

  Widget _buildProfessionalTabs(
    BuildContext context,
    AsyncValue currentUserAsync,
  ) {
    final labels = _users.map((u) {
      return currentUserAsync.maybeWhen(
        data: (currentUser) =>
            getDisplayName(u.id, currentUser.id, {u.id: u.name}),
        orElse: () => u.name,
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
        ),
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
        labelStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
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
    final tripsAsync = ref.watch(allTripsProvider);
    final tripNameById = {
      for (final trip in (tripsAsync.value ?? const []))
        if (trip.tripId != null) trip.tripId!: (trip.tripName ?? 'Trip'),
    };

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(leaveEntriesByYearProvider((user.id, _selectedYear)).notifier)
            .refresh();
        ref.invalidate(leaveTrackingProvider((user.id, _selectedYear)));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppUi.pageHorizontalPadding,
          14,
          AppUi.pageHorizontalPadding,
          24,
        ),
        children: [
          leaveTrackingAsync.maybeWhen(
            data: (tracking) => tracking == null
                ? const SizedBox.shrink()
                : _buildLeaveBalanceCard(context, tracking),
            loading: () => const _ShimmerCard(),
            error: (e, _) => Text('Error: $e'),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppUi.itemGap),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => ManageLeaveTotalsPage(
                      userId: user.id,
                      year: _selectedYear,
                    ),
                  ),
                )
                .then((_) {
                  ref.invalidate(
                    leaveTrackingProvider((user.id, _selectedYear)),
                  );
                }),
            icon: const Icon(Icons.settings_rounded),
            label: const Text('Leave Settings'),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                      color: Theme.of(context).textTheme.labelMedium?.color,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No leave entries for $_selectedYear',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.labelMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            AppCardSurface(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: List.generate(leaveEntriesState.entries.length, (i) {
                  final entry = leaveEntriesState.entries[i];
                  return Dismissible(
                    key: ValueKey(entry.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red.shade500,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
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
                    confirmDismiss: (_) async {
                      await _deleteEntry(userId: user.id, entry: entry);
                      return false;
                    },
                    child: _buildLeaveEntryCard(
                      context,
                      entry,
                      tripName: entry.tripId == null
                          ? null
                          : tripNameById[entry.tripId!],
                      showDivider: i < leaveEntriesState.entries.length - 1,
                    ),
                  );
                }),
              ),
            ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Swipe left on an entry to delete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.labelMedium?.color,
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
      AppFeedback.showSuccess(context, 'Leave entry deleted');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, 'Failed to delete: $e');
    }
  }

  Widget _buildLeaveBalanceCard(BuildContext context, LeaveTracking tracking) {
    final theme = Theme.of(context);
    final utilizationPercent = tracking.remaining > 0
        ? (tracking.used / tracking.total) * 100
        : 100;

    return AppCardSurface(
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
                      color: theme.textTheme.labelMedium?.color,
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
                  color: tracking.remaining > 0
                      ? AppTheme.accent
                      : AppTheme.negative,
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
              backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                tracking.isExhausted ? AppTheme.negative : AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Used',
                '${tracking.used}',
                AppTheme.warning,
              ),
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.labelMedium?.color,
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

  Widget _buildLeaveEntryCard(
    BuildContext context,
    LeaveEntry entry, {
    String? tripName,
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);
    final tripIcon = entry.tripId != null
        ? Icons.luggage_rounded
        : Icons.calendar_today_rounded;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(tripIcon, color: AppTheme.accent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.description,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM yyyy').format(entry.leaveDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    if (tripName != null && tripName.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        tripName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 0,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${entry.daysUsed}d',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
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
            indent: 76,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return _LoadingPulse(
      child: AppCardSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SkeletonLine(width: 84, height: 12),
            SizedBox(height: 10),
            _SkeletonLine(width: 128, height: 18),
            SizedBox(height: 22),
            _SkeletonLine(width: double.infinity, height: 8),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [_SkeletonStat(), _SkeletonStat()],
            ),
          ],
        ),
      ),
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
          padding: const EdgeInsets.only(bottom: 10),
          child: _LoadingPulse(
            child: AppCardSurface(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  _SkeletonCircle(size: 42),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonLine(width: 124, height: 14),
                        SizedBox(height: 8),
                        _SkeletonLine(width: 96, height: 12),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  _SkeletonLine(width: 28, height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingPulse extends StatelessWidget {
  const _LoadingPulse({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.65, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, builtChild) {
        return Opacity(opacity: value, child: builtChild);
      },
      onEnd: () {},
      child: child,
    );
  }
}

class _SkeletonStat extends StatelessWidget {
  const _SkeletonStat();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SkeletonLine(width: 44, height: 10),
        SizedBox(height: 6),
        _SkeletonLine(width: 32, height: 14),
      ],
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
