import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../core/realtime/realtime_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/current_user_provider.dart';
import '../home/data/home_providers.dart';
import '../home/presentation/home_page.dart';
import '../personal/data/personal_providers.dart';
import '../personal/presentation/personal_page.dart';
import '../settings/presentation/settings_sheet.dart';
import '../shared_expenses/data/shared_expenses_providers.dart';
import '../shared_expenses/presentation/shared_expenses_page.dart';

class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key});

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  late PageController _pageController;
  late RealtimeService _realtime;
  late DateTime _selectedMonth;
  bool _fabMenuExpanded = false;
  // Only build a tab's page once it has actually been visited.
  // Home (index 0) is pre-initialized so it loads immediately.
  final Set<int> _initializedTabs = {0};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    // Capture before any possible disposal so dispose() never touches ref.
    _realtime = ref.read(realtimeServiceProvider);
    _realtime.subscribe();
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 180)), // Limit to 6 months in future
    );
    if (picked != null) setState(() => _selectedMonth = picked);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _navigateToForm(String type) {
    _closeFabMenu();
    // Navigate to transaction form with type parameter
    // We'll create this form page next
    Navigator.of(context).pushNamed(
      '/transaction-form',
      arguments: TransactionFormArgs(
        type: type,
        initialMonth: DateTime.now(), //today, but user can change it in the form
      ),
    );
  }

  void _toggleFabMenu() {
    setState(() => _fabMenuExpanded = !_fabMenuExpanded);
  }

  void _closeFabMenu() {
    setState(() => _fabMenuExpanded = false);
  }

  List<({String label, String type, IconData icon})> _getFabMenuItems() {
    return switch (_currentIndex) {
      0 => [ // Home tab
        (label: 'Deposit', type: 'deposit', icon: Icons.savings_outlined),
        (label: 'Shared Expense', type: 'shared_expense', icon: Icons.group_outlined),
        (label: 'Personal Expense', type: 'personal_expense', icon: Icons.receipt_rounded),
      ],
      1 => [ // Personal tab
        (label: 'Personal Expense', type: 'personal_expense', icon: Icons.receipt_rounded),
        (label: 'Deposit', type: 'deposit', icon: Icons.savings_outlined),
      ],
      2 => [ // Shared tab
        (label: 'Shared Expense', type: 'shared_expense', icon: Icons.group_outlined),
        (label: 'Add Trip', type: 'add_trip', icon: Icons.luggage_outlined),
      ],
      _ => [],
    };
  }

  Widget _buildFabMenu(ThemeData theme) {
    final items = _getFabMenuItems();
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Scrim (tap to close)
        if (_fabMenuExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeFabMenu,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
        // Menu items (animated)
        if (_fabMenuExpanded)
          Positioned(
            bottom: 70,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(items.length, (i) {
                final delay = Duration(milliseconds: i * 50);
                return _AnimatedFabMenuItem(
                  delay: delay,
                  label: items[i].label,
                  icon: items[i].icon,
                  onTap: () => _navigateToForm(items[i].type),
                );
              }),
            ),
          ),
        // Main FAB button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _toggleFabMenu,
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: AnimatedRotation(
              turns: _fabMenuExpanded ? 0.125 : 0, // 45 degrees
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Use the cached reference — ref is no longer safe to call here.
    // Fire-and-forget: unsubscribe must complete before widget destruction
    unawaited(_realtime.unsubscribe());
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Force-refetch all data caches on resume.
      ref.invalidate(poolBalanceProvider);
      ref.invalidate(userDebtsProvider);
      ref.invalidate(inflowOutflowProvider);
      ref.invalidate(userLeavesProvider);
      ref.invalidate(personalTransactionsProvider);
      ref.invalidate(personalUserNamesProvider);
      ref.invalidate(poolMonthExpenseProvider);
      ref.invalidate(poolSummaryTotalProvider);
      ref.invalidate(activeTripProvider);
      ref.invalidate(sharedTransactionsProvider);
      ref.invalidate(sharedUserNamesProvider);
      _realtime.unsubscribe().then((_) => _realtime.subscribe());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_realtime.unsubscribe());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Previous month button ──
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.arrow_left_rounded,
                    size: 20,
                    color: theme.textTheme.labelMedium?.color,
                  ),
                  onPressed: _previousMonth,
                  tooltip: 'Previous month',
                ),
              ),
              const SizedBox(width: 4),
              // ── Month selector (tap to open picker) ──
              GestureDetector(
                onTap: _pickMonth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.yMMMM().format(_selectedMonth),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: theme.textTheme.labelMedium?.color,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // ── Next month button ──
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.arrow_right_rounded,
                    size: 20,
                    color: theme.textTheme.labelMedium?.color,
                  ),
                  onPressed: _nextMonth,
                  tooltip: 'Next month',
                ),
              ),
            ],
          ),
        ),
        actions: [
          userAsync.maybeWhen(
            data: (user) {
              final letter = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () => showSettings(context, ref),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ),
              );
            },
            orElse: () => const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: SizedBox(width: 36, height: 36),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFabMenu(theme),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _initializedTabs.add(index);
            _currentIndex = index;
          });
        },
        children: [
          HomePage(selectedMonth: _selectedMonth),
          _initializedTabs.contains(1)
              ? PersonalPage(selectedMonth: _selectedMonth)
              : const SizedBox.shrink(),
          _initializedTabs.contains(2)
              ? SharedExpensesPage(selectedMonth: _selectedMonth)
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.dividerTheme.color ?? Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() {
              _initializedTabs.add(i);
              _currentIndex = i;
            });
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Personal'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group_rounded), label: 'Shared'),
          ],
        ),
      ),
    );
  }
}

// ── FAB Menu Item Widget ───────────────────────────────────────────────────

class _AnimatedFabMenuItem extends StatefulWidget {
  const _AnimatedFabMenuItem({
    required this.delay,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final Duration delay;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_AnimatedFabMenuItem> createState() => _AnimatedFabMenuItemState();
}

class _AnimatedFabMenuItemState extends State<_AnimatedFabMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.dividerTheme.color ?? Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Transaction Form Arguments ─────────────────────────────────────────────

class TransactionFormArgs {
  final String type;
  final DateTime initialMonth;

  TransactionFormArgs({
    required this.type,
    required this.initialMonth,
  });
}
