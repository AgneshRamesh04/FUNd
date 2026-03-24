# Screen-by-Screen Implementation Checklist

This document tracks which screens have been updated to use the Supabase backend.

## Completed ✅

### Core Infrastructure
- [x] `lib/main.dart` - Supabase initialization
- [x] `lib/core/models/` - All model classes created
- [x] `lib/core/services/supabase_service.dart` - Database operations
- [x] `lib/core/services/auth_service.dart` - Authentication
- [x] `lib/core/data/transaction_repository.dart` - Repository with Supabase integration
- [x] `lib/features/transactions/presentation/transaction_form_screen.dart` - Updated to create real Supabase transactions

---

## Pending ⏳

### Home Feature (`lib/features/home/`)

#### home_screen.dart
**Status:** Uses `TransactionRepository().getPersonalGroups()` but via old `FutureBuilder`

**What needs updating:**
- Replace `DemoData.mockTransactions` references with real repository calls
- Implement real-time listeners for pool balance updates
- Subscribe to pool_summary view table changes
- Subscribe to user_debts view table changes

**Key changes needed:**
```dart
// OLD
final summary = FinanceService.calculate(
  allTransactions: DemoData.mockTransactions,
  selectedDate: _selectedDate,
);

// NEW
final summary = await TransactionRepository().getHomeSummary(_selectedDate);
// Returns FinanceSummary with data from pool_summary view table
```

#### home_screen widgets
**Status:** Uses hardcoded demo data

**Files:**
- `lib/features/home/presentation/widgets/home_components.dart`
- `lib/features/home/presentation/widgets/multi_action_fab.dart`

**What needs updating:**
- Subscribe to real-time transaction changes
- Update balance displays when pool_balance view changes
- Refresh monthly summaries when pool_summary view updates

---

### Personal Feature (`lib/features/personal/`)

#### personal_screen.dart
**Status:** Uses `TransactionRepository().getPersonalGroups()`

**What needs updating:**
- Already fetches from repository ✅ (mostly done)
- Should subscribe to borrow transaction changes
- Implement pull-to-refresh or real-time updates

**Current implementation:**
```dart
// This is already using repository
FutureBuilder(
  future: TransactionRepository().getPersonalGroups(),
  ...
)
```

**Enhancement needed:**
```dart
// Add real-time listener
TransactionRepository().subscribeToTransactionChanges((_) {
  setState(() {}); // Refresh when transactions change
});
```

---

### Shared Feature (`lib/features/shared/`)

#### shared_screen.dart
**Status:** Likely using demo data

**What needs updating:**
- Replace demo data with `TransactionRepository().getSharedExpenseTransactions()`
- Implement real-time listeners for shared expenses
- Update trip display with real trip data

**Files:**
- `lib/features/shared/presentation/shared_screen.dart`
- `lib/features/shared/presentation/trip_form_screen.dart`

#### trip_form_screen.dart
**Status:** Uses demo trips

**What needs updating:**
- Update to create real Supabase trips via `TransactionRepository().createTrip()`
- Subscribe to trip changes
- Fetch trip details for editing

---

### Leave Feature (`lib/features/leave/`)

#### leave_screen.dart (if exists)
**Status:** Uses demo leave data

**What needs updating:**
- Fetch leave tracking from `SupabaseService().getLeaveTracking(userId)`
- Update leave via `SupabaseService().updateLeaveTracking()`
- Subscribe to leave tracking changes

---

## Implementation Priority

### Phase 1 (High Priority)
1. **home_screen.dart** - Most visible, critical for app functionality
   - Replace mock data with real pool summaries
   - Implement real-time balance updates

2. **shared_screen.dart** - User-facing expense tracking
   - Load real shared expenses
   - Real-time expense updates

3. **trip_form_screen.dart** - Create/edit trips
   - Save trips to Supabase
   - Load existing trips

### Phase 2 (Medium Priority)
1. **personal_screen.dart** - Already using repository, just needs real-time
   - Add subscriptions for live updates

2. **leave feature** - Optional in MVP
   - Implement leave tracking display
   - Update leave used counter

### Phase 3 (Polish)
1. Error handling improvements
2. Loading states
3. Pull-to-refresh
4. Offline caching

---

## Template for Updating a Screen

When updating a screen to use Supabase, follow this pattern:

```dart
class _MyScreenState extends State<MyScreen> {
  late final _subscription; // For real-time updates

  @override
  void initState() {
    super.initState();
    _subscribeToChanges();
  }

  void _subscribeToChanges() {
    _subscription = TransactionRepository()
        .subscribeToTransactionChanges((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // Clean up subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Use repository instead of demo data
      future: TransactionRepository().getAllTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildUI(snapshot.data!);
      },
    );
  }

  Widget _buildUI(List<TransactionModel> transactions) {
    // Render UI with real data
    return ListView(...);
  }
}
```

---

## Important Reminders

1. **Always check authentication** before operations
   ```dart
   final authService = AuthService();
   if (!authService.isAuthenticated) {
     // Navigate to login
   }
   ```

2. **Handle loading states** during data fetches
   ```dart
   if (snapshot.connectionState == ConnectionState.waiting) {
     return const CircularProgressIndicator();
   }
   ```

3. **Clean up subscriptions** in dispose()
   ```dart
   @override
   void dispose() {
     _subscription.cancel();
     super.dispose();
   }
   ```

4. **Use FutureBuilder or StreamBuilder** for async data
   - FutureBuilder for one-time fetches
   - StreamBuilder for real-time updates

5. **Keep error messages user-friendly**
   ```dart
   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text('Failed to load transactions')),
   );
   ```

---

## Questions to Ask When Updating

- [ ] Is this screen using demo data or repository?
- [ ] Does it need real-time updates?
- [ ] Is authentication required?
- [ ] Are subscriptions cleaned up in dispose()?
- [ ] Is error handling in place?
- [ ] Are loading states shown?
- [ ] Does it work with the backend models?

