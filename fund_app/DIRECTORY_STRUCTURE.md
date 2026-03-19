# FUNd App - Complete Directory Structure

```
fund_app/
│
├── 📱 lib/
│   │
│   ├── 🎯 core/                              # Reusable core layer
│   │   │
│   │   ├── constants/
│   │   │   └── app_constants.dart            # App-wide constants (Supabase config, table names)
│   │   │
│   │   ├── di/                               # Dependency Injection
│   │   │   ├── service_locator.dart          # GetIt setup
│   │   │   └── riverpod_providers.dart       # Riverpod providers (NEW)
│   │   │
│   │   ├── models/                           # Data models with JSON serialization
│   │   │   ├── user_model.dart               # User profile
│   │   │   ├── transaction_model.dart        # Transaction with types
│   │   │   ├── trip_model.dart               # Trip grouping
│   │   │   └── leave_tracking_model.dart     # Leave balance tracking
│   │   │
│   │   ├── repositories/                     # Data access layer
│   │   │   ├── transaction_repository.dart   # Transaction CRUD
│   │   │   ├── user_repository.dart          # User CRUD
│   │   │   └── trip_repository.dart          # Trip CRUD
│   │   │
│   │   ├── services/                         # External integrations & business logic
│   │   │   ├── supabase_service.dart         # Supabase client initialization
│   │   │   ├── auth_service.dart             # Authentication (sign up, sign in, logout)
│   │   │   ├── transaction_service.dart      # Transaction API calls & streaming
│   │   │   └── calculation_service.dart      # Financial calculations (pool balance, debts, etc.)
│   │   │
│   │   └── theme/
│   │       └── app_theme.dart                # Material Design 3 theme
│   │                                         # Colors, text styles, spacing, dimensions
│   │
│   ├── 🎨 features/                          # Feature modules (feature-first)
│   │   │
│   │   ├── home/                             # Home/Dashboard feature
│   │   │   ├── providers/
│   │   │   │   └── home_provider.dart        # State: pool balance, debts, summary
│   │   │   └── screens/
│   │   │       └── home_screen.dart          # Dashboard UI
│   │   │
│   │   ├── personal/                         # Personal/Borrow feature
│   │   │   └── screens/
│   │   │       └── personal_screen.dart      # Borrow transactions list
│   │   │
│   │   ├── shared/                           # Shared expenses feature
│   │   │   └── screens/
│   │   │       └── shared_screen.dart        # Shared expenses list
│   │   │
│   │   └── transactions/                     # Add transaction feature
│   │       ├── providers/
│   │       │   └── add_transaction_provider.dart  # Form state management
│   │       └── screens/
│   │           └── add_transaction_screen.dart   # Add transaction form
│   │
│   └── main.dart                             # App entry point
│                                             # Supabase init, Riverpod setup, navigation
│
├── 📊 build/                                  # Flutter build output
│
├── 🔧 android/                                # Android native code
├── 🔧 ios/                                    # iOS native code
├── 🔧 web/                                    # Web support (optional)
├── 🔧 windows/                                # Windows support (optional)
├── 🔧 macos/                                  # macOS support (optional)
├── 🔧 linux/                                  # Linux support (optional)
│
├── 📚 test/                                   # Test files
│   └── widget_test.dart                      # Example test
│
├── ⚙️ pubspec.yaml                            # Dependencies
├── ⚙️ pubspec.lock                            # Locked versions
├── ⚙️ analysis_options.yaml                   # Lint rules
├── ⚙️ .gitignore                              # Git ignore rules
│
├── 📖 README.md                               # Original README
├── 📖 BUILD_COMPLETE.md                       # This build summary
├── 📖 IMPLEMENTATION_GUIDE.md                 # Setup & database guide
├── 📖 NEXT_STEPS.dart                         # Integration steps
├── 📖 FILE_SUMMARY.md                         # Detailed file listing
├── 📖 QUICK_REFERENCE.md                      # Quick lookup guide
│
└── 📄 fund_app.iml                            # Project configuration
```

---

## 🎯 Feature Folder Structure

Each feature follows this pattern:

```
feature_name/
├── providers/              # Riverpod state management
│   └── feature_provider.dart
├── screens/               # UI screens
│   ├── feature_screen.dart
│   └── component_screen.dart (optional)
├── widgets/              # Reusable widgets (optional)
│   └── custom_widget.dart
└── models/               # Feature-specific models (if needed)
    └── feature_model.dart
```

---

## 📋 Core Service Dependencies

```
Services Layer
├── SupabaseService (singleton)
│   └── Initializes Supabase client
│
├── AuthService (depends on SupabaseService)
│   └── Sign up, sign in, sign out, reset password
│
├── TransactionService (depends on SupabaseService)
│   └── CRUD operations, real-time streaming
│
└── CalculationService (no dependencies)
    └── Pure business logic (math)

Repositories Layer
├── TransactionRepository (depends on TransactionService)
├── UserRepository (depends on SupabaseService)
└── TripRepository (depends on SupabaseService)

Features Layer
├── HomeScreen
│   └── depends on homeProvider
│       └── depends on HomeNotifier
│           └── depends on TransactionRepository, CalculationService
│
├── PersonalScreen
│   └── depends on borrowTransactionsProvider
│
├── SharedScreen
│   └── depends on sharedExpensesProvider
│
└── AddTransactionScreen
    └── depends on addTransactionProvider
        └── depends on AddTransactionNotifier
            └── depends on TransactionRepository
```

---

## 📱 App Navigation Flow

```
MyApp (main)
  └── HomeNavigation (StatefulWidget)
      ├── BottomNavigationBar (3 tabs)
      │   ├── Home Tab
      │   │   └── HomeScreen
      │   │       ├── Pool Balance Card
      │   │       ├── Monthly Summary
      │   │       ├── Money Owed Section
      │   │       └── Recent Transactions
      │   │
      │   ├── Personal Tab
      │   │   └── PersonalScreen
      │   │       └── Borrow Transactions List
      │   │
      │   └── Shared Tab
      │       └── SharedScreen
      │           └── Shared Expenses List
      │
      └── FloatingActionButton (+)
          └── Opens AddTransactionScreen
              └── Modal BottomSheet
                  ├── Type Selection
                  ├── Description Field
                  ├── Amount Field
                  ├── User Selection
                  ├── Date Picker
                  ├── Notes Field
                  └── Submit Button
```

---

## 🗄️ Database Schema (Supabase)

```
users
├── id (UUID, PK)
├── name (TEXT)
├── email (TEXT, UNIQUE)
└── created_at (TIMESTAMP)

transactions
├── id (UUID, PK)
├── type (TEXT: borrow|deposit|shared_expense|pool_expense)
├── description (TEXT)
├── amount (DECIMAL)
├── paid_by (UUID, FK to users)
├── received_by (UUID, FK to users, nullable)
├── split_type (TEXT: equal|custom, nullable)
├── split_data (JSONB, nullable)
├── date (DATE)
├── trip_id (UUID, FK to trips, nullable)
├── notes (TEXT, nullable)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)

trips
├── id (UUID, PK)
├── name (TEXT)
├── start_date (DATE)
├── end_date (DATE)
└── created_at (TIMESTAMP)

leave_tracking
├── id (UUID, PK)
├── user_id (UUID, FK to users)
├── used (DECIMAL)
├── balance (DECIMAL)
├── month (INTEGER)
├── year (INTEGER)
└── created_at (TIMESTAMP)
```

---

## 🔄 Data Flow Example

### When user adds a borrow transaction:

```
User taps (+) FloatingActionButton
    ↓
AddTransactionScreen modal opens
    ↓
User selects "Borrow" type
    ↓
User fills: amount=$50, date=today, notes="groceries"
    ↓
User taps "Add Transaction"
    ↓
AddTransactionNotifier.submitTransaction() called
    ↓
transactionRepository.createTransaction() called
    ↓
TransactionService.createTransaction() called
    ↓
Supabase transactions table INSERT
    ↓
Row created in DB with:
{
  id: auto-generated,
  type: "borrow",
  description: "groceries",
  amount: 50.00,
  paid_by: "pool",
  received_by: current_user_id,
  date: today,
  created_at: now,
  updated_at: now
}
    ↓
homeProvider auto-refreshes (Riverpod)
    ↓
HomeNotifier._initialize() runs
    ↓
transactionRepository.getTransactions() fetches all
    ↓
calculationService.calculatePoolBalance() runs
    ↓
Pool balance updated: was $100 → now $50
    ↓
HomeState updates
    ↓
HomeScreen rebuilds with new pool balance
    ↓
Modal closes, success toast shows
    ↓
User sees updated home screen
```

---

## 📊 Class Diagram

```
Models
├── User
├── Transaction
├── Trip
└── LeaveTracking

Services
├── SupabaseService (singleton)
├── AuthService
├── TransactionService
└── CalculationService

Repositories
├── TransactionRepository
├── UserRepository
└── TripRepository

Providers (Riverpod)
├── supabaseServiceProvider
├── authServiceProvider
├── transactionRepositoryProvider
├── homeProvider (StateNotifierProvider)
├── addTransactionProvider (StateNotifierProvider)
├── poolBalanceProvider (FutureProvider)
├── userDebtsProvider (FutureProvider)
└── ... more providers

Screens (Consumer Widgets)
├── HomeScreen
├── PersonalScreen
├── SharedScreen
└── AddTransactionScreen

State Classes
├── HomeState
└── AddTransactionState

Notifiers
├── HomeNotifier
└── AddTransactionNotifier
```

---

## 🎨 Theme Constants

```
AppTheme
├── Colors
│   ├── primaryColor
│   ├── secondaryColor
│   ├── accentColor
│   ├── successColor
│   ├── warningColor
│   ├── errorColor
│   ├── backgroundColor
│   ├── surfaceColor
│   ├── borderColor
│   ├── textPrimary
│   ├── textSecondary
│   └── textTertiary
│
├── Text Styles
│   ├── headlineLarge
│   ├── headlineMedium
│   ├── headlineSmall
│   ├── titleLarge
│   ├── titleMedium
│   ├── titleSmall
│   ├── bodyLarge
│   ├── bodyMedium
│   └── bodySmall
│
├── Spacing
│   ├── spacing2 through spacing32
│   └── Used in padding, margins
│
└── Border Radius
    ├── radiusSmall
    ├── radiusMedium
    ├── radiusLarge
    └── radiusXLarge
```

---

## 📦 Dependencies Overview

```
pubspec.yaml
├── Flutter SDK
├── Supabase (backend)
├── Riverpod (state management)
├── GetIt (service locator)
├── JSON Annotation (serialization)
├── Intl (date formatting)
├── Shared Preferences (local storage)
└── Dio (HTTP client)

build_runner (dev)
└── JSON Serializable (code generation)
```

---

## ✨ Feature Completeness

```
Home Screen:
├── ✅ UI Layout
├── ✅ State Management (Provider)
├── ✅ Pool Balance Display
├── ✅ Monthly Summary
├── ✅ User Debts Display
├── ✅ Recent Transactions
├── ✅ Pull to Refresh
├── ✅ Loading States
├── ✅ Error Handling
└── ✅ Empty States

Personal Screen:
├── ✅ UI Layout
├── ✅ Transaction List
├── ✅ Empty State
└── 🔲 Connected to real data (TODO)

Shared Screen:
├── ✅ UI Layout
├── ✅ Transaction List
├── ✅ Empty State
└── 🔲 Connected to real data (TODO)

Add Transaction:
├── ✅ UI Layout
├── ✅ Type Selection
├── ✅ Form Fields
├── ✅ State Management
├── ✅ Form Validation
├── ✅ Date Picker
├── ✅ Error Messages
├── ✅ Loading States
└── ✅ Success Feedback
```

---

This structure provides a **production-ready, scalable foundation** for your FUNd app!
