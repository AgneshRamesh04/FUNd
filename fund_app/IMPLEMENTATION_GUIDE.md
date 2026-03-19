# FUNd App - Implementation Guide

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # App-wide constants
│   ├── di/
│   │   └── service_locator.dart        # Dependency injection setup
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── transaction_model.dart
│   │   ├── trip_model.dart
│   │   └── leave_tracking_model.dart
│   ├── repositories/
│   │   ├── transaction_repository.dart
│   │   ├── user_repository.dart
│   │   └── trip_repository.dart
│   ├── services/
│   │   ├── supabase_service.dart       # Supabase initialization
│   │   ├── auth_service.dart           # Authentication
│   │   ├── transaction_service.dart    # Transaction API calls
│   │   └── calculation_service.dart    # Business logic
│   └── theme/
│       └── app_theme.dart              # App styling
│
├── features/
│   ├── home/
│   │   ├── providers/
│   │   │   └── home_provider.dart      # State management
│   │   └── screens/
│   │       └── home_screen.dart
│   │
│   ├── personal/
│   │   └── screens/
│   │       └── personal_screen.dart    # Borrow transactions
│   │
│   ├── shared/
│   │   └── screens/
│   │       └── shared_screen.dart      # Shared expenses
│   │
│   └── transactions/
│       ├── providers/
│       │   └── add_transaction_provider.dart  # Add transaction state
│       └── screens/
│           └── add_transaction_screen.dart
│
└── main.dart                           # App entry point
```

## Setup Instructions

### 1. Install Dependencies
Run the following command to get all packages:
```bash
cd fund_app
flutter pub get
```

### 2. Configure Supabase
Update `lib/core/constants/app_constants.dart` with your Supabase credentials:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Generate JSON Serialization Code
Run code generation for JSON models:
```bash
flutter pub run build_runner build
```

### 4. Set Up Supabase Database

Create the following tables in your Supabase PostgreSQL database:

#### users table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### transactions table
```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL,
  description TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  paid_by UUID NOT NULL REFERENCES users(id),
  received_by UUID REFERENCES users(id),
  split_type TEXT,
  split_data JSONB,
  date DATE NOT NULL,
  trip_id UUID REFERENCES trips(id),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### trips table
```sql
CREATE TABLE trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### leave_tracking table
```sql
CREATE TABLE leave_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  used DECIMAL(10, 2) NOT NULL,
  balance DECIMAL(10, 2) NOT NULL,
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5. Enable Realtime (Optional)
In Supabase, enable realtime for the `transactions` table:
- Go to Database → Replication
- Enable realtime for `transactions` table

### 6. Configure Authentication
- Go to Authentication → Providers in Supabase
- Enable Email/Password authentication

## Features

### Home Screen
- **Pool Balance**: Total available money in the shared pool
- **Monthly Summary**: Shows monthly inflow and outflow for each user
- **Money Owed to Pool**: Displays how much each user owes to the pool
- **Recent Transactions**: Quick view of latest transactions

### Personal Screen
- Displays all **Borrow transactions** (Pool → User)
- Shows amount, date, and notes for each borrow
- Reduces pool balance and increases user debt

### Shared Screen
- Displays **Shared Expenses** between users
- Shows who paid and the split details
- Splits cost equally between users by default

### Add Transaction
- **Borrow**: Take money from pool (Pool → User)
- **Deposit**: Add money to pool (User → Pool)
- **Shared Expense**: Split expense between users (User → Shared)
- **Pool Expense**: Fund pays for something (Pool → External)

## State Management

The app uses **Riverpod** for state management:
- `homeProvider`: Manages home screen data (pool balance, debts, summary)
- `addTransactionProvider`: Manages add transaction form state

### Adding Providers

Update providers with actual dependencies:
```dart
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final calcService = ref.watch(calculationServiceProvider);
  return HomeNotifier(transactionRepo, calcService);
});
```

## Key Classes

### Models
- `User`: User profile information
- `Transaction`: Individual transaction record
- `Trip`: Trip grouping for expenses
- `LeaveTracking`: Leave balance tracking

### Services
- `SupabaseService`: Backend initialization and client access
- `AuthService`: Handle authentication
- `TransactionService`: CRUD operations for transactions
- `CalculationService`: Business logic (balance, debt calculations)

### Repositories
- `TransactionRepository`: Transaction data access layer
- `UserRepository`: User data access layer
- `TripRepository`: Trip data access layer

## Calculation Service

The `CalculationService` handles all financial calculations:

```dart
// Calculate pool balance
double poolBalance = calculationService.calculatePoolBalance(transactions);

// Calculate user debt to pool
double userDebt = calculationService.calculateUserDebt(transactions, userId);

// Get monthly summary
Map summary = calculationService.getMonthlysSummary(
  transactions,
  userId,
  month,
  year,
);
```

## TODO Items

- [ ] Connect home provider to Riverpod dependency injection
- [ ] Connect add transaction provider to Riverpod dependency injection
- [ ] Connect personal screen to transaction provider (show borrows)
- [ ] Connect shared screen to transaction provider (show shared expenses)
- [ ] Implement authentication flow (sign up, sign in, sign out)
- [ ] Add real-time updates using Supabase subscriptions
- [ ] Add error handling and validation
- [ ] Add navigation between screens
- [ ] Implement trip tracking feature
- [ ] Add offline support
- [ ] Add unit and widget tests
- [ ] Generate JSON serialization files (models.g.dart)

## Running the App

### iOS
```bash
flutter run
```

### Android
```bash
flutter run
```

### Build Release
```bash
flutter build ios
flutter build apk
```

## Useful Resources

- [Flutter Documentation](https://flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/flutter/introduction)
- [Supabase Realtime](https://supabase.com/docs/reference/realtime/overview)

## Notes

- The app uses **Feature-first Clean Architecture** for scalability
- All calculations are handled in the **Calculation Service Layer** (not UI)
- **Supabase is the single source of truth** for all data
- The app supports **real-time synchronization** between users
- Use `build_runner` for JSON code generation when adding new models

## Support

For issues or questions, refer to the SRS.md for detailed requirements or check the inline code comments.
