# Architecture Diagrams - FUNd Supabase Integration

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      iOS Application                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           Presentation Layer (Features)                  │   │
│  │  ┌────────────────┐  ┌─────────────────┐  ┌──────────┐  │   │
│  │  │ home_screen    │  │ shared_screen   │  │personal  │  │   │
│  │  │                │  │                 │  │_screen   │  │   │
│  │  └────────┬───────┘  └────────┬────────┘  └─────┬────┘  │   │
│  │           │                   │                  │        │   │
│  │  ┌────────────────────────────┴──────────────────┴─────┐ │   │
│  │  │  transaction_form_screen (Add/Edit)                 │ │   │
│  │  │  trip_form_screen                                   │ │   │
│  │  └───────────────────┬────────────────────────────────┘ │   │
│  └────────────────────────┼─────────────────────────────────┘   │
│                           │                                       │
│  ┌────────────────────────▼──────────────────────────────────┐   │
│  │        Repository Layer (Single Source)                   │   │
│  │  ┌────────────────────────────────────────────────────┐   │   │
│  │  │        TransactionRepository                       │   │   │
│  │  │  • In-memory caching                              │   │   │
│  │  │  • Cache invalidation                             │   │   │
│  │  │  • Real-time subscriptions management             │   │   │
│  │  │  • Orchestrates multiple services                 │   │   │
│  │  └────────────┬─────────────────────────────────────┘   │   │
│  └───────────────┼──────────────────────────────────────────┘   │
│                  │                                                │
│    ┌─────────────┼─────────────┬──────────────┬──────────────┐   │
│    │             │             │              │              │   │
│  ┌─▼──────┐   ┌──▼──────┐  ┌──▼──────┐   ┌──▼──────┐   ┌───▼──┐ │
│  │Supabase│   │Auth     │  │Models   │   │Services │   │Config│ │
│  │Service │   │Service  │  │         │   │         │   │      │ │
│  │        │   │         │  │ 8 Model │   │ Real-   │   │      │ │
│  │• CRUD  │   │• Sign   │  │ Classes │   │ time    │   │      │ │
│  │• Query │   │  Up/In  │  │         │   │ Subs    │   │      │ │
│  │• Filter│   │• Session│  │ With    │   │         │   │      │ │
│  │        │   │  Mgmt   │  │ Ser/De  │   │         │   │      │ │
│  └─┬──────┘   └──┬──────┘  └──┬──────┘   └──┬──────┘   └───┬──┘ │
│    │             │             │             │              │    │
│  ┌─▼─────────────▼─────────────▼─────────────▼──────────────▼──┐ │
│  │                    Supabase Client                           │ │
│  │  • PostgreSQL driver                                        │ │
│  │  • Real-time WebSocket listener                            │ │
│  │  • Auth state manager                                      │ │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
└─────────────────────────┼────────────────────────────────────────┘
                          │
                   ┌──────▼──────────────────┐
                   │  Supabase Backend       │
                   │  (supabase.co)          │
                   ├─────────────────────────┤
                   │ PostgreSQL Database     │
                   │  • users                │
                   │  • transactions         │
                   │  • trips                │
                   │  • leave_tracking       │
                   │  • pool_balance (view)  │
                   │  • pool_summary (view)  │
                   │  • user_debts (view)    │
                   │  • trip_summary (view)  │
                   ├─────────────────────────┤
                   │ Real-time Engine        │
                   │  (WebSocket subscriptions)
                   │                         │
                   │ Authentication          │
                   │  (Email/Password)       │
                   └─────────────────────────┘
```

---

## Data Flow - Creating a Transaction

```
User Interaction
    ↓
transaction_form_screen
    ↓
User enters:
  • Description
  • Amount
  • Date
    ↓
_saveTransaction()
    ↓
Create TransactionModel
  • Get userId from AuthService
  • Generate monthKey ("2026-03")
  • Set type from initialType
    ↓
TransactionRepository.createTransaction(model)
    ↓
SupabaseService.createTransaction(model)
    ↓
model.toMap() → JSON
    ↓
Supabase REST API
    ↓
INSERT into transactions table
    ↓
Generate UUID for id
    ↓
Return created transaction
    ↓
Update Home Summary View
    ↓
Update Pool Balance View
    ↓
Real-time listeners trigger
    ↓
UI rebuilds with new data
```

---

## Data Flow - Real-time Updates

```
Backend Change Event
    ↓
Postgres Trigger (transaction inserted)
    ↓
Supabase Real-time Engine
    ↓
Broadcast PostgresChangeEvent
    ↓
─────────┬─────────────────────────────────
          │
    Subscribed Client (iOS App)
    ↓
RealtimeChannel.onPostgresChanges
    ↓
Callback triggered
    ↓
TransactionModel.fromMap(newRecord)
    ↓
onTransactionChanged(transaction)
    ↓
setState(() {}) in Screen
    ↓
UI Rebuilds with new data
```

---

## State Management

```
┌───────────────────────────────────────────────┐
│        Application State Flow                  │
├───────────────────────────────────────────────┤
│                                               │
│  1. Cold Start                                │
│     └─→ Supabase initialized                 │
│         AuthService initialized              │
│         App ready                            │
│                                               │
│  2. User Navigation                          │
│     Home Screen
│      └─→ FutureBuilder fetches data          │
│          ├─ getAllTransactions()             │
│          ├─ getHomeSummary()                 │
│          └─ Subscribe to changes             │
│                                               │
│  3. Data Mutation                            │
│     User creates transaction
│      └─→ TransactionFormScreen               │
│          └─→ TransactionRepository           │
│              └─→ SupabaseService             │
│                  └─→ INSERT to DB            │
│                      ├─ Cache invalidated    │
│                      └─→ Real-time event     │
│                          └─→ All subscribers │
│                              updated         │
│                                               │
│  4. Real-time Update                         │
│     Other user modifies data
│      └─→ Database changes                    │
│          └─→ PostgreSQL trigger              │
│              └─→ Real-time broadcast         │
│                  └─→ My app receives event   │
│                      └─→ setState()          │
│                          └─→ UI refreshes    │
│                                               │
│  5. View Updates                             │
│     Cached data used first
│      └─→ View tables recalculated on backend│
│          └─→ New summary fetched             │
│              └─→ UI displays new totals      │
│                                               │
└───────────────────────────────────────────────┘
```

---

## Cache Strategy

```
┌────────────────────────────────────────┐
│   TransactionRepository Caches         │
├────────────────────────────────────────┤
│                                        │
│  _transactionsCache                    │
│    ├─ Populated on first fetch         │
│    ├─ Invalidated on CREATE/UPDATE     │
│    └─ Invalidated on DELETE            │
│                                        │
│  _tripsCache                           │
│    ├─ Populated on first fetch         │
│    └─ Invalidated on mutations         │
│                                        │
│  _poolSummaryCache                     │
│    ├─ Keyed by month                   │
│    └─ Invalidated on pool changes      │
│                                        │
│  _userDebtsCache                       │
│    ├─ Keyed by userId                  │
│    └─ Invalidated on debt changes      │
│                                        │
│  Refresh Strategy:                     │
│    ├─ Automatic invalidation on save   │
│    ├─ Manual refresh() method          │
│    └─ Real-time subscription updates   │
│                                        │
└────────────────────────────────────────┘
```

---

## Authentication Flow

```
┌──────────────────────────────────────────────┐
│         Authentication Lifecycle             │
├──────────────────────────────────────────────┤
│                                              │
│  Not Authenticated                           │
│    │                                         │
│    ├─→ AuthScreen (show login/signup)       │
│    │                                         │
│    ├─ User enters credentials               │
│    │    └─→ AuthService.signUp()            │
│    │        or signIn()                     │
│    │                                         │
│    └─→ Supabase Auth API                    │
│         ├─ Validate credentials             │
│         ├─ Create session token             │
│         └─ Save user_id to auth state       │
│                                              │
│  Authenticated                               │
│    │                                         │
│    ├─→ AuthService.isAuthenticated = true   │
│    ├─→ AuthService.currentUserId = uuid     │
│    │                                         │
│    ├─→ MainNavigationWrapper loads          │
│    │    ├─ HomeScreen                       │
│    │    ├─ PersonalScreen                   │
│    │    └─ SharedScreen                     │
│    │                                         │
│    ├─ All data ops include userId           │
│    │    ├─ TransactionRepository gets user  │
│    │    └─ RLS policy filters by user       │
│    │                                         │
│    ├─ Session maintained with refresh token │
│    │    └─ Auto-renewed by Supabase         │
│    │                                         │
│    └─ Subscribe to auth state changes       │
│         └─ onAuthStateChange listener       │
│                                              │
│  Logout                                      │
│    └─→ AuthService.signOut()                │
│        ├─ Clear session                     │
│        ├─ Clear cache                       │
│        └─ Navigate back to AuthScreen       │
│                                              │
└──────────────────────────────────────────────┘
```

---

## Transaction Types & Rules

```
┌─────────────────────────────────────────────────┐
│    Transaction Type Logic                        │
├─────────────────────────────────────────────────┤
│                                                  │
│  BORROW (Pool → User)                           │
│  ├─ Reduces pool balance                        │
│  ├─ Increases user debt                         │
│  ├─ Created from: PersonalScreen                │
│  └─ Example: Borrow $100 from pool              │
│                                                  │
│  DEPOSIT (User → Pool)                          │
│  ├─ Increases pool balance                      │
│  ├─ Decreases user debt                         │
│  ├─ Created from: TransactionForm               │
│  └─ Example: Add $500 to pool                   │
│                                                  │
│  SHARED_EXPENSE (User → Shared)                 │
│  ├─ Records shared cost                         │
│  ├─ Reduces pool (indirectly)                   │
│  ├─ Created from: SharedScreen                  │
│  └─ Example: $100 dinner (split 50/50)          │
│                                                  │
│  POOL_EXPENSE (Pool → External)                 │
│  ├─ Reduces pool balance                        │
│  ├─ External payment (tax, fee, etc)            │
│  ├─ Created from: AdminPanel (if exists)        │
│  └─ Example: Bank fee                           │
│                                                  │
│  Backend View Calculations:                     │
│  ├─ pool_balance view: Sum all effects          │
│  ├─ user_debts view: Calculate per user         │
│  ├─ pool_summary view: Monthly aggregates       │
│  └─ trip_summary view: Trip costs               │
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## File Organization

```
lib/
│
├── main.dart ✅ (UPDATED)
│   └─ Initializes Supabase and services
│
├── core/
│   ├── config/
│   │   └── supabase_config.dart ✅ (NEW)
│   │       └─ Centralized credentials
│   │
│   ├── models/ ✅ (NEW - 8 files)
│   │   ├── user_model.dart
│   │   ├── transaction_model.dart
│   │   ├── trip_model.dart
│   │   ├── leave_tracking_model.dart
│   │   ├── pool_balance_model.dart
│   │   ├── pool_summary_model.dart
│   │   ├── user_debts_model.dart
│   │   └── trip_summary_model.dart
│   │
│   ├── services/ ✅ (2 NEW)
│   │   ├── supabase_service.dart
│   │   │   └─ CRUD + real-time (40+ methods)
│   │   └── auth_service.dart
│   │       └─ Authentication management
│   │
│   ├── constants/
│   │   └── demo_data.dart ⏸️ (No longer used)
│   │
│   └── data/
│       └── transaction_repository.dart ✅ (UPDATED)
│           └─ Orchestrates services + caching
│
├── features/
│   ├── home/
│   │   ├── domain/
│   │   │   ├── finance_service.dart
│   │   │   └── finance_summary.dart
│   │   └── presentation/
│   │       ├── home_screen.dart ⏳ (Needs update)
│   │       └── widgets/
│   │
│   ├── personal/
│   │   └── presentation/
│   │       └── personal_screen.dart ⏳ (Partial update)
│   │
│   ├── shared/
│   │   └── presentation/
│   │       ├── shared_screen.dart ⏳ (Needs update)
│   │       └── trip_form_screen.dart ⏳ (Needs update)
│   │
│   ├── leave/
│   │   └── ... ⏳ (Needs update)
│   │
│   └── transactions/
│       ├── domain/
│       │   └── transaction_model.dart
│       │       └─ TransactionType enum (KEPT)
│       └── presentation/
│           └── transaction_form_screen.dart ✅ (UPDATED)
│
└── Documentation (root):
    ├── SUPABASE_INTEGRATION.md ✅ (NEW)
    ├── SCREENS_TODO.md ✅ (NEW)
    ├── IMPLEMENTATION_SUMMARY.md ✅ (NEW)
    ├── FILE_MANIFEST.md ✅ (NEW)
    └── QUICK_REFERENCE.md ✅ (NEW)

Legend:
✅ = Complete
⏳ = Pending
⏸️ = No longer used
```

---

## Error Handling Flow

```
┌─────────────────────────────────────────────────┐
│      Error Handling Strategy                     │
├─────────────────────────────────────────────────┤
│                                                  │
│  Try-Catch in Services                          │
│    │                                            │
│    ├─ SupabaseService methods wrap DB calls    │
│    ├─ AuthService wraps auth operations        │
│    └─ Print debug logs on error                │
│                                                  │
│  Bubble to Repository                           │
│    │                                            │
│    ├─ Repository catches service errors        │
│    ├─ Returns null or empty list on error      │
│    ├─ Logs with context                        │
│    └─ Invalidates cache if needed              │
│                                                  │
│  Handle in UI                                   │
│    │                                            │
│    ├─ FutureBuilder shows error state          │
│    ├─ SnackBar displays user message           │
│    ├─ Retry button offered                     │
│    └─ Graceful degradation                     │
│                                                  │
│  Examples:                                      │
│    ├─ Network error → "Network error, retry?"  │
│    ├─ Auth error → "Please log in again"       │
│    ├─ Parse error → "Data format error"        │
│    └─ Unknown error → "Something went wrong"   │
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## Performance Considerations

```
┌──────────────────────────────────────────────────┐
│   Performance Optimizations                       │
├──────────────────────────────────────────────────┤
│                                                   │
│  Caching Strategy                                │
│  ├─ Repository maintains in-memory cache        │
│  ├─ Cache invalidated on mutations              │
│  ├─ Reduces DB queries                          │
│  └─ Improves perceived performance              │
│                                                   │
│  Database Queries                                │
│  ├─ month_key field for fast month filtering    │
│  ├─ Indexed on frequently queried fields        │
│  ├─ View tables precalculate summaries          │
│  └─ Limits queries to needed data               │
│                                                   │
│  Real-time Updates                               │
│  ├─ Only essential tables subscribed            │
│  ├─ Filtered at database level                  │
│  ├─ Debounced UI refreshes                      │
│  └─ Minimal network overhead                    │
│                                                   │
│  UI Rendering                                    │
│  ├─ FutureBuilder for efficient loading         │
│  ├─ ListView.builder for large lists            │
│  ├─ Minimal rebuilds with setState              │
│  └─ Lazy loading for heavy screens              │
│                                                   │
└──────────────────────────────────────────────────┘
```

---

**For detailed explanations, see [SUPABASE_INTEGRATION.md](./SUPABASE_INTEGRATION.md)**

