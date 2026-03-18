# FUNd - Shared Money Management App

A Flutter mobile application for two users to manage a shared pool of money with real-time synchronization via Supabase.

## Project Overview

FUNd enables users to:
- Deposit money into a shared pool
- Borrow money temporarily
- Record and track shared expenses
- View real-time balances and debts
- Track monthly summaries and financial activity

### Architecture

```
Flutter iOS App (User A)
        ↕ Realtime Sync
Supabase Backend (PostgreSQL)
        ↕ Realtime Sync
Flutter iOS App (User B)
```

## Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile framework (iOS focus)
- **Dart** - Programming language
- **Riverpod** - State management
- **Supabase Flutter SDK** - Backend integration

### Backend
- **Supabase** - PostgreSQL database + Authentication + Real-time updates
- **PostgreSQL** - Data persistence
- **Row-Level Security (RLS)** - Data access control

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── features/
│   ├── auth/                          # Authentication feature
│   ├── home/                          # Home screen feature
│   │   └── screens/
│   │       └── home_screen.dart
│   ├── personal/                      # Personal transactions
│   │   └── screens/
│   │       └── personal_screen.dart
│   ├── shared/                        # Shared expenses
│   │   └── screens/
│   │       └── shared_screen.dart
│   └── transactions/                  # Transaction management
│       └── screens/
│           └── add_transaction_screen.dart
└── core/
    ├── database/
    │   └── models.dart               # Data models
    ├── services/
    │   ├── supabase_service.dart     # Supabase integration
    │   └── transaction_service.dart  # Business logic
    ├── providers/
    │   └── app_providers.dart        # Riverpod providers
    ├── constants/
    │   └── app_constants.dart        # App-wide constants
    ├── theme/
    │   └── app_theme.dart            # UI theme configuration
    └── utils/                         # Utility functions
```

## Data Models

### Users
```dart
User {
  id: UUID
  name: String
  email: String
  created_at: DateTime
}
```

### Transactions
```dart
Transaction {
  id: UUID
  type: TransactionType (borrow | deposit | shared_expense | pool_expense)
  description: String
  amount: Double
  paid_by: String
  received_by: String
  split_type: SplitType (equal | custom)
  split_data: JSON (optional)
  date: DateTime
  trip_id: UUID (optional)
  notes: String (optional)
  created_at: DateTime
  updated_at: DateTime
}
```

### Trips
```dart
Trip {
  id: UUID
  name: String
  start_date: DateTime
  end_date: DateTime
  created_at: DateTime
}
```

### Leave Tracking
```dart
LeaveTracking {
  id: UUID
  user_id: UUID
  used: Double
  balance: Double
  month: Int
  year: Int
}
```

## Transaction Types & Effects

| Type | Effect |
|------|--------|
| **Borrow** | Pool ↓, User debt ↑ |
| **Deposit** | Pool ↑, User debt ↓ |
| **Shared Expense** | Split between users |
| **Pool Expense** | Pool ↓ |

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (included with Flutter)
- Xcode (for iOS development)
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd FUNd
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new project on [Supabase](https://supabase.com)
   - Copy the project URL and anon key
   - Create `.env` file:
     ```
     SUPABASE_URL=https://your-project.supabase.co
     SUPABASE_ANON_KEY=your-anon-key-here
     ```

4. **Generate Model Files**
   ```bash
   flutter pub run build_runner build
   ```

5. **Run the App**
   ```bash
   # iOS
   flutter run -d ios
   
   # Or use Xcode
   open ios/Runner.xcworkspace
   ```

## Database Setup

### SQL Commands

```sql
-- Users Table
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Transactions Table
CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  type TEXT NOT NULL,
  description TEXT NOT NULL,
  amount DECIMAL(12, 2) NOT NULL,
  paid_by TEXT NOT NULL,
  received_by TEXT NOT NULL,
  split_type TEXT DEFAULT 'equal',
  split_data JSONB,
  date DATE NOT NULL,
  trip_id UUID REFERENCES trips(id),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Trips Table
CREATE TABLE trips (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Leave Tracking Table
CREATE TABLE leave_tracking (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  used DECIMAL(8, 2),
  balance DECIMAL(8, 2),
  month INT,
  year INT
);
```

## Core Services

### TransactionService
Handles all financial calculations:
- `calculatePoolBalance()` - Total pool balance
- `calculateUserDebt()` - Individual user debt
- `calculateMonthlySummary()` - Monthly financial overview
- `getTripSummary()` - Trip-specific expenses
- `validateTransaction()` - Input validation
- `getSettlementAmount()` - Settlement between users

### SupabaseService
Manages backend integration:
- Authentication (sign up, sign in, sign out)
- CRUD operations for all entities
- Real-time subscriptions
- Data synchronization

## State Management (Riverpod)

Key providers:
- `currentUserProvider` - Current authenticated user
- `transactionsProvider` - All transactions
- `poolBalanceProvider` - Calculated pool balance
- `userDebtProvider` - Individual user debt
- `monthlySummaryProvider` - Monthly overview
- `settlementsProvider` - Settlements between users

## UI Screens

### Home Screen
- Pool balance overview
- Monthly summary (inflow/outflow)
- Money owed to pool per user
- Leave tracking information

### Personal Screen
- List of borrow transactions
- User-specific borrowing activity
- Transaction details

### Shared Screen
- List of shared expenses
- User's share in each expense
- Expense details and notes

### Add Transaction Screen
- Single reusable form for all transaction types
- Smart field population based on transaction type
- Date picker
- Optional notes

## Key Features

✅ **Real-Time Sync** - Instant updates across devices
✅ **Ledger-Based** - All transactions recorded for audit trail
✅ **Derived Calculations** - Balances computed from transactions
✅ **Responsive UI** - Bottom navigation with floating action button
✅ **Type-Safe** - Dart strong typing with models
✅ **Efficient** - Performance optimized with <2s initial load

## Future Enhancements

- [ ] Analytics dashboard
- [ ] Spending charts
- [ ] Budget alerts
- [ ] Export (CSV/PDF)
- [ ] Push notifications
- [ ] iOS widgets
- [ ] Offline support
- [ ] Dark mode

## Development Phases

### Phase 1 – MVP (Current)
- ✅ Core transactions
- ✅ Pool balance
- ✅ Real-time sync
- ✅ Basic UI

### Phase 2
- [ ] Trip tracking
- [ ] Enhanced leave tracking
- [ ] Settlement recommendations

### Phase 3
- [ ] Offline support
- [ ] Advanced analytics
- [ ] Export functionality

## Performance Requirements

| Metric | Target |
|--------|--------|
| Initial Load | < 2 seconds |
| UI Updates | < 500ms |
| Real-time Sync | Instant |

## Code Style & Conventions

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Use const constructors where possible
- Organize imports alphabetically

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## Troubleshooting

### Supabase Connection Issues
- Verify `.env` file has correct credentials
- Check Supabase project is active
- Ensure Row-Level Security policies are configured

### Build Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### iOS Specific
```bash
# Clear iOS build
rm -rf ios/Pods ios/Podfile.lock
flutter clean
flutter pub get
```

## Contributing

1. Create a feature branch: `git checkout -b feature/feature-name`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/feature-name`
4. Submit a pull request

## License

This project is proprietary and confidential.

## Support

For issues, questions, or suggestions, please create an issue in the repository.

---

**Last Updated:** March 2026
**Version:** 1.0.0
