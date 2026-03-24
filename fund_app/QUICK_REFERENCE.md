# Quick Reference Card - FUNd Supabase Integration

## 🚀 Quick Start

### Add Credentials (Required)
```dart
// lib/core/config/supabase_config.dart
const String supabaseUrl = 'https://your-project.supabase.co';
const String supabaseAnonKey = 'your-anon-key';
```

### Get Current User
```dart
final authService = AuthService();
final userId = authService.currentUserId; // Returns String?
final user = await authService.getCurrentUserProfile(); // Returns UserModel?
```

---

## 📝 Common Operations

### Create Transaction
```dart
final transaction = TransactionModel(
  id: '',
  type: 'borrow', // 'deposit', 'shared_expense', 'pool_expense'
  userId: userId,
  description: 'My transaction',
  amount: 100.0,
  date: DateTime.now(),
  monthKey: '2026-03',
);
await TransactionRepository().createTransaction(transaction);
```

### Get All Transactions
```dart
final repo = TransactionRepository();
final transactions = await repo.getAllTransactions();
```

### Get Transactions by Type
```dart
final borrows = await repo.getTransactionsByType('borrow');
final deposits = await repo.getTransactionsByType('deposit');
final shared = await repo.getTransactionsByType('shared_expense');
```

### Get Monthly Summary
```dart
final summary = await repo.getPoolSummary(DateTime.now());
print('Balance: ${summary?.poolBalance}');
print('Inflow: ${summary?.monthlyInflow}');
print('Outflow: ${summary?.monthlyOutflow}');
```

### Get User Debts
```dart
final allDebts = await repo.getAllUserDebts();
// userDebts > 0 = user owes pool
// userDebts < 0 = pool owes user

final userDebt = await repo.getUserDebts(userId);
print('User owes: ${userDebt?.userDebts}');
```

### Get All Trips
```dart
final trips = await repo.getAllTrips();
```

### Create Trip
```dart
final trip = TripModel(
  id: '',
  name: 'Bali Vacation',
  startDate: DateTime(2026, 4, 1),
  endDate: DateTime(2026, 4, 10),
);
await repo.createTrip(trip);
```

### Get Transactions for Trip
```dart
final tripTxs = await repo.getTransactionsByTrip(tripId);
```

---

## 🔐 Authentication

### Sign Up
```dart
final authService = AuthService();
await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
);
```

### Sign In
```dart
await authService.signIn(
  email: 'user@example.com',
  password: 'password123',
);
```

### Sign Out
```dart
await authService.signOut();
```

### Check if Authenticated
```dart
if (authService.isAuthenticated) {
  // User is logged in
}
```

### Listen to Auth Changes
```dart
authService.onAuthStateChange((state) {
  print('Auth state: ${state.event}');
});
```

---

## 📡 Real-time Updates

### Subscribe to Transaction Changes
```dart
TransactionRepository().subscribeToTransactionChanges((transaction) {
  print('Transaction changed: ${transaction.id}');
  setState(() {}); // Rebuild UI
});
```

### Subscribe to Trip Changes
```dart
TransactionRepository().subscribeToTripChanges((trip) {
  print('Trip changed: ${trip.id}');
  setState(() {});
});
```

### Subscribe to Pool Balance Changes
```dart
TransactionRepository().subscribeToPoolBalanceChanges(() {
  print('Pool balance updated!');
  setState(() {});
});
```

### Subscribe to Debt Changes
```dart
TransactionRepository().subscribeToUserDebtsChanges(() {
  print('User debts updated!');
  setState(() {});
});
```

### Clean Up Subscriptions
```dart
late final RealtimeChannel _subscription;

@override
void initState() {
  _subscription = TransactionRepository()
      .subscribeToTransactionChanges((_) => setState(() {}));
}

@override
void dispose() {
  _subscription.unsubscribe(); // Clean up!
  super.dispose();
}
```

---

## 🎨 UI Patterns

### FutureBuilder Pattern
```dart
FutureBuilder<List<TransactionModel>>(
  future: TransactionRepository().getAllTransactions(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return const Text('No data');
    }
    
    final transactions = snapshot.data!;
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(transactions[index].description ?? ''));
      },
    );
  },
)
```

### StreamBuilder Pattern (Real-time)
```dart
// Not directly - use FutureBuilder + subscriptions
// Or convert Stream:
Stream<List<TransactionModel>> getTransactionStream() async* {
  yield await TransactionRepository().getAllTransactions();
  
  TransactionRepository().subscribeToTransactionChanges((_) async {
    yield await TransactionRepository().getAllTransactions();
  });
}

StreamBuilder<List<TransactionModel>>(
  stream: getTransactionStream(),
  builder: (context, snapshot) {
    // Same as FutureBuilder
  },
)
```

### Error Handling Pattern
```dart
try {
  await TransactionRepository().createTransaction(transaction);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Transaction created!')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

---

## 🔍 Query Patterns

### Filter Transactions
```dart
final repo = TransactionRepository();

// All transactions
final all = await repo.getAllTransactions();

// By month
final march = await repo.getTransactionsByMonth(DateTime(2026, 3));

// By type
final borrowed = await repo.getTransactionsByType('borrow');

// By trip
final tripTxs = await repo.getTransactionsByTrip(tripId);
```

### Get Summary Data
```dart
// Home screen summary
final summary = await repo.getHomeSummary(DateTime.now());

// Pool summary for specific month
final poolSummary = await repo.getPoolSummary(DateTime(2026, 3));

// Trip summary
final tripSummary = await TransactionRepository()
    .subscribeToTripChanges((_) => {}); // Manual fetch not shown
```

---

## 📅 Date Handling

### Format Month Key
```dart
final now = DateTime.now();
final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
// Result: "2026-03"
```

### Parse Date Strings
```dart
final dateString = "2026-03-25";
final date = DateTime.parse(dateString); // DateTime(2026, 3, 25)
```

### Format for Display
```dart
import 'package:intl/intl.dart';

final date = DateTime.now();
final formatted = DateFormat('MMM d, yyyy').format(date); // "Mar 25, 2026"
```

---

## ⚠️ Common Pitfalls

### ❌ Don't: Use hardcoded user IDs
```dart
// WRONG
const userId = "uuid-user-a";
```

### ✅ Do: Get from AuthService
```dart
final userId = AuthService().currentUserId;
```

### ❌ Don't: Forget to generate month_key
```dart
// WRONG - Missing month_key
final tx = TransactionModel(
  id: '',
  type: 'borrow',
  userId: userId,
  // ...
);
```

### ✅ Do: Always include month_key
```dart
// CORRECT
final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
final tx = TransactionModel(
  id: '',
  type: 'borrow',
  userId: userId,
  monthKey: monthKey,
  // ...
);
```

### ❌ Don't: Keep subscriptions without cleanup
```dart
// WRONG - Memory leak!
void initState() {
  TransactionRepository().subscribeToTransactionChanges((_) => setState(() {}));
}
```

### ✅ Do: Store and cleanup subscriptions
```dart
late final RealtimeChannel _subscription;

@override
void initState() {
  super.initState();
  _subscription = TransactionRepository()
      .subscribeToTransactionChanges((_) => setState(() {}));
}

@override
void dispose() {
  _subscription.unsubscribe();
  super.dispose();
}
```

---

## 🧪 Testing Checklist

- [ ] Supabase credentials configured
- [ ] `flutter pub get` runs without errors
- [ ] App initializes without crashes
- [ ] Can sign up new user
- [ ] Can sign in existing user
- [ ] Can create transaction
- [ ] Transaction appears in list immediately
- [ ] Switching users shows correct data
- [ ] Real-time updates work (open in two places)
- [ ] Pool summary shows correct values
- [ ] User debts display correctly
- [ ] Trip operations work
- [ ] Subscriptions don't cause memory leaks

---

## 📚 Reference Files

- **Integration Guide:** [SUPABASE_INTEGRATION.md](./SUPABASE_INTEGRATION.md)
- **Screen Updates:** [SCREENS_TODO.md](./SCREENS_TODO.md)
- **Implementation Summary:** [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)
- **File Manifest:** [FILE_MANIFEST.md](./FILE_MANIFEST.md)

---

## 🆘 Troubleshooting

**"Supabase not initialized"**
→ Check main.dart has `await Supabase.initialize(...)`

**"User is null"**
→ Make sure user is signed in with AuthService

**"View table returns empty"**
→ Check backend SQL and database state

**"Real-time not updating"**
→ Verify `unsubscribe()` is in dispose, not causing early cleanup

**"Type error with dates"**
→ Always use `DateTime.parse()` for strings from database

---

**Print this page and keep it handy while developing!** 📋

