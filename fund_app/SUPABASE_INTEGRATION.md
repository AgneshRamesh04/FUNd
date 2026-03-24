# FUNd Supabase Integration Guide

## Overview
The FUNd app has been successfully integrated with Supabase backend. This document outlines the key changes, architecture, and setup instructions.

---

## What Changed

### 1. **New Dependencies**
- `supabase_flutter: ^2.5.0` - Added to pubspec.yaml

### 2. **New Model Layer** (`lib/core/models/`)
Created comprehensive models for all database tables:

**Base Tables:**
- `user_model.dart` - User profiles with monthly obligations
- `transaction_model.dart` - Ledger transactions with type, user, amount, date
- `trip_model.dart` - Trip metadata with dates
- `leave_tracking_model.dart` - Annual leave per user/year

**View Tables (Backend Calculations):**
- `pool_balance_model.dart` - Current pool balance (real-time)
- `pool_summary_model.dart` - Monthly inflow/outflow aggregates
- `user_debts_model.dart` - Calculated debt per user (±value)
- `trip_summary_model.dart` - Trip totals with duration and expenses

### 3. **New Services Layer** (`lib/core/services/`)
- `supabase_service.dart` - Core database operations & real-time listeners
- `auth_service.dart` - Authentication & user session management
- `supabase_config.dart` - Centralized Supabase configuration

### 4. **Updated TransactionRepository** (`lib/core/data/`)
- Now uses `SupabaseService` instead of mock data
- Supports all CRUD operations for transactions & trips
- Fetches from backend view tables for financial summaries
- Provides real-time subscription methods
- Maintains backward compatibility with existing UI layer

### 5. **Updated UI Layer**
- `transaction_form_screen.dart` - Now creates real Supabase transactions
- Uses `AuthService` to get current user ID
- Generates `month_key` automatically for efficient querying
- Added error handling and loading states

### 6. **Main App Initialization** (`main.dart`)
- Initializes Supabase client
- Sets up SupabaseService and AuthService
- Maintains existing UI structure

---

## Architecture Flow

```
┌─────────────────────────────────────────────┐
│         UI Layer (Features)                  │
│  - home_screen, personal_screen, etc.      │
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│      Repository Layer (Repository)           │
│  - TransactionRepository (orchestrator)     │
│  - Caches data, manages subscriptions       │
└────────────────────┬────────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
    ┌────▼──────┐ ┌──▼────────┐ ┌──▼─────────┐
    │ Supabase  │ │  Auth     │ │ View       │
    │ Service   │ │  Service  │ │ Models     │
    │ (CRUD +   │ │ (User     │ │ (Pool      │
    │ Real-time)│ │  Session) │ │  Balance)  │
    └────┬──────┘ └──────────┘ └────────────┘
         │
         └────────────┬─────────────┐
                      │             │
              ┌───────▼─────┐ ┌────▼────────┐
              │  Supabase   │ │   Firebase  │
              │  PostgreSQL │ │  Real-time  │
              │   Database  │ │  (Subscriptions)
              └─────────────┘ └─────────────┘
```

---

## Setup Instructions

### 1. **Add Supabase Configuration**

Update `lib/core/config/supabase_config.dart`:
```dart
const String supabaseUrl = 'https://your-project.supabase.co';
const String supabaseAnonKey = 'your-anon-key';
```

Get these values from your Supabase project settings.

### 2. **Initialize Supabase in main()**

Already done in `lib/main.dart`:
```dart
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
);

SupabaseService().initialize(Supabase.instance.client);
AuthService().initialize(Supabase.instance.client);
```

### 3. **Run Flutter Pub Get**
```bash
flutter pub get
```

---

## Usage Examples

### Getting All Transactions
```dart
final repository = TransactionRepository();
final transactions = await repository.getAllTransactions();
```

### Creating a Transaction
```dart
final transaction = TransactionModel(
  id: '', // Supabase generates
  type: 'borrow',
  userId: currentUserId,
  description: 'Borrowed from pool',
  amount: 100.0,
  date: DateTime.now(),
  monthKey: '2026-03',
);

await TransactionRepository().createTransaction(transaction);
```

### Getting Financial Summary (from view tables)
```dart
final summary = await TransactionRepository().getPoolSummary(DateTime.now());
// Returns: pool balance, monthly inflow, monthly outflow
```

### Getting User Debts
```dart
final debts = await TransactionRepository().getAllUserDebts();
// Returns: List of user debts (positive = owes pool, negative = pool owes user)
```

### Real-time Subscriptions
```dart
TransactionRepository().subscribeToTransactionChanges((transaction) {
  print('Transaction updated: ${transaction.id}');
  setState(() {});
});
```

---

## Authentication Flow

### Sign Up
```dart
final authService = AuthService();
await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  name: 'User Name',
);
```

### Sign In
```dart
await authService.signIn(
  email: 'user@example.com',
  password: 'password123',
);
```

### Check Authentication Status
```dart
final authService = AuthService();
if (authService.isAuthenticated) {
  final userId = authService.currentUserId;
  final user = await authService.getCurrentUserProfile();
}
```

---

## Key Data Models

### TransactionModel
```dart
TransactionModel(
  id: 'uuid',
  type: 'borrow' | 'deposit' | 'shared_expense' | 'pool_expense',
  userId: 'user-uuid',
  description: 'Transaction description',
  amount: 100.0,
  date: DateTime.now(),
  notes: 'Optional notes',
  tripId: 'optional-trip-uuid',
  monthKey: '2026-03', // For efficient month-based queries
)
```

### PoolSummaryModel (View Table)
```dart
PoolSummaryModel(
  month: DateTime(2026, 3),
  poolBalance: 5000.0,
  monthlyInflow: 2000.0,
  monthlyOutflow: 1500.0,
)
```

### UserDebtsModel (View Table)
```dart
UserDebtsModel(
  userId: 'user-uuid',
  userDebts: 500.0, // Positive = owes pool, Negative = pool owes user
)
```

---

## Database Schema Reference

### Base Tables

**users**
- id (uuid, PK)
- name (text)
- email (text)
- monthly_obligation (numeric)
- created_at (timestamp)

**transactions**
- id (uuid, PK)
- type (text) - 'borrow', 'deposit', 'shared_expense', 'pool_expense'
- user_id (uuid, FK)
- description (text)
- amount (numeric)
- date (date)
- notes (text)
- trip_id (uuid, FK, optional)
- month_key (text) - e.g., "2026-03"
- created_at (timestamp)

**trips**
- id (uuid, PK)
- name (text)
- start_date (date)
- end_date (date)
- created_at (timestamp)

**leave_tracking**
- id (uuid, PK)
- user_id (uuid, FK)
- used (integer)
- total (integer)
- year (integer)
- created_at (timestamp)
- updated_at (timestamp)

### View Tables (Backend Calculations)

**pool_balance** - Returns current pool balance
**pool_summary** - Returns monthly inflow/outflow aggregates
**user_debts** - Returns calculated debt per user
**trip_summary** - Returns trip totals and duration

---

## Real-time Synchronization

The app subscribes to changes on these view tables:
- `transactions` - Update UI when new transactions added
- `trips` - Update UI when trips modified
- `pool_balance` - Real-time balance updates
- `user_debts` - Real-time debt calculation updates

Subscriptions are managed in `TransactionRepository`:
```dart
TransactionRepository()
  .subscribeToTransactionChanges((_) => setState(() {}));
```

---

## Migration Notes

### Old vs New Architecture

| Aspect | Old (Mock) | New (Supabase) |
|--------|-----------|----------------|
| Data Source | DemoData class | Supabase PostgreSQL |
| User ID | Hardcoded constants | From Auth |
| Balance Calculation | Frontend (FinanceService) | Backend view tables |
| Real-time | None | WebSockets via Supabase |
| Transactions | `Map<String, dynamic>` | `TransactionModel` class |
| Authentication | None | Supabase Auth |

### Files to Update When Connecting UI

1. **home_screen.dart** - Replace `DemoData.mockTransactions` with `TransactionRepository().getAllTransactions()`
2. **personal_screen.dart** - Already uses repository
3. **shared_screen.dart** - Update to fetch from `TransactionRepository`
4. **leave/** - Update to use `SupabaseService().getLeaveTracking(userId)`

---

## Error Handling

All methods include try-catch blocks and print debug messages. For production:

```dart
try {
  final transactions = await repository.getAllTransactions();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.toString()}')),
  );
}
```

---

## Next Steps

1. ✅ Replace Supabase URL and anonymous key in `supabase_config.dart`
2. ✅ Run `flutter pub get`
3. ✅ Update remaining screens to use `TransactionRepository` instead of demo data
4. ✅ Test authentication flow with Supabase auth
5. ✅ Verify real-time subscriptions work correctly
6. ✅ Test transaction creation through the form

---

## Important Notes

- **Keep transaction_model.dart in features/** - Maintains the `TransactionType` enum for UI form logic
- **Cache invalidation** - Repository automatically invalidates caches when data changes
- **Month key format** - Always format as "YYYY-MM" for consistent querying
- **User ID requirement** - All operations require authenticated user (except public reads if configured)
- **View tables** - Frontend only reads from view tables for calculations, never directly from transaction aggregation

