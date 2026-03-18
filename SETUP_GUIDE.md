# FUNd Flutter Project - Setup & Development Guide

## Quick Start

### 1. Install Flutter
If you haven't installed Flutter yet:
- Visit https://flutter.dev/docs/get-started/install
- Follow the platform-specific installation
- Verify installation: `flutter doctor`

### 2. Install Dependencies
```bash
cd /Users/mvka/DevProjects/FUNd
flutter pub get
```

### 3. Generate Model Files
```bash
flutter pub run build_runner build
```

### 4. Configure Supabase
- Create account at https://supabase.com
- Create a new project
- Copy the project URL and anon key
- Create `.env` file (copy from `.env.example`):
  ```
  SUPABASE_URL=your-project-url
  SUPABASE_ANON_KEY=your-anon-key
  ```

### 5. Run the Project
```bash
flutter run
```

## Project Structure Overview

### `/lib` - Source Code
- **`main.dart`** - App entry point with bottom navigation
- **`features/`** - Feature modules
  - `home/` - Home screen with monthly overview
  - `personal/` - Borrow transactions
  - `shared/` - Shared expenses
  - `transactions/` - Add/edit transaction form
  - `auth/` - Authentication (to be implemented)
- **`core/`** - Shared functionality
  - `database/` - Data models
  - `services/` - Business logic & API integration
  - `providers/` - Riverpod state management
  - `constants/` - App strings, theme, config
  - `theme/` - Material theme configuration
  - `utils/` - Utility functions and widgets

### Key Files

**Models** - `/lib/core/database/models.dart`
- Transaction, User, Trip, LeaveTracking classes
- Enums: TransactionType, SplitType
- Support classes: MonthlySummary, TripSummary

**Transaction Service** - `/lib/core/services/transaction_service.dart`
- Core business logic for all calculations
- Pool balance calculation
- User debt calculation
- Monthly summary
- Trip summary
- Settlement amounts

**Supabase Service** - `/lib/core/services/supabase_service.dart`
- Backend integration
- CRUD operations
- Real-time subscriptions
- Authentication

**Providers** - `/lib/core/providers/app_providers.dart`
- Riverpod FutureProviders for data fetching
- Cached data management
- State invalidation

**UI Theme** - `/lib/core/theme/app_theme.dart`
- Material 3 design
- Color scheme
- Typography
- Component themes

**Widgets** - `/lib/core/utils/widgets.dart`
- Reusable components
- FinancialCard, EmptyState, LoadingWidget, etc.

## Data Models

### Transaction Types
- `borrow` - User borrows from pool
- `deposit` - User adds money to pool
- `shared_expense` - Shared between users
- `pool_expense` - Pool pays external entity

### Split Types
- `equal` - Split 50/50 between users
- `custom` - Custom split amounts in JSON

## Development Workflow

### Adding a New Feature

1. **Create feature folder structure**
   ```
   lib/features/feature_name/
   ├── screens/
   ├── widgets/
   ├── models/
   └── services/
   ```

2. **Create models** in `models.dart` if needed

3. **Create screens** in `screens/` folder
   - Use Riverpod for state management
   - Use provided providers for data

4. **Create service** if business logic needed
   - Add to `lib/core/services/`

5. **Add providers** in `lib/core/providers/app_providers.dart`

6. **Integrate to navigation** in `main.dart`

### Example: Adding a Trip Screen
```bash
# Create feature structure
mkdir -p lib/features/trips/screens

# Create screen file
touch lib/features/trips/screens/trips_screen.dart

# Update providers if needed
vim lib/core/providers/app_providers.dart

# Add to navigation
vim lib/main.dart
```

## State Management (Riverpod)

### Consuming a Provider
```dart
final transactions = ref.watch(transactionsProvider);

transactions.when(
  data: (txns) => ListView(...),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(message: error.toString()),
);
```

### Invalidating Provider
```dart
ref.refresh(transactionsProvider);
```

### Creating New Provider
```dart
final myProvider = FutureProvider<List<Data>>((ref) async {
  return await someAsyncFunction();
});
```

## Common Tasks

### Fetching Data
```dart
final data = ref.watch(myProvider);
```

### Calculating Balances
```dart
final balance = TransactionService.calculatePoolBalance(transactions);
final debt = TransactionService.calculateUserDebt(userId, transactions);
```

### Creating Transactions
```dart
final supabase = ref.watch(supabaseServiceProvider);
final transaction = await supabase.createTransaction(txn);
```

### Real-time Updates
```dart
// Subscribe in service
final channel = supabase.subscribeToTransactions();

// Handle updates
channel.onPostgresChanges(
  event: PostgresChangeEvent.all,
  schema: 'public',
  table: 'transactions',
  callback: (payload) {
    // Refresh providers
    ref.refresh(transactionsProvider);
  },
);
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/core/services/transaction_service_test.dart

# Generate coverage report
flutter test --coverage
```

## Build & Release

### iOS Build
```bash
flutter build ios --release
```

### Android Build
```bash
flutter build apk --release
flutter build appbundle --release
```

## Debugging

### Enable logging
```dart
import 'package:logger/logger.dart';

final log = Logger();
log.d('Debug message');
```

### VS Code Debugging
- Set breakpoints
- Press F5 or Run → Start Debugging
- Use debug console for variable inspection

### Dart DevTools
```bash
flutter pub global activate devtools
devtools
```

## Common Issues

### Supabase Connection Fails
- Check `.env` credentials
- Verify Supabase project is active
- Check Row-Level Security policies

### Flutter Clean Build
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Model Generation Issues
```bash
flutter pub run build_runner clean
flutter pub run build_runner build
```

## Performance Optimization

- Use `const` constructors
- Cache calculated values in providers
- Minimize rebuilds with `.select()`
- Use `ListView.builder` for long lists
- Profile with DevTools

## Code Quality

### Run Linter
```bash
flutter analyze
```

### Format Code
```bash
dart format lib/
```

### Follow Conventions
- Use snake_case for files/folders
- Use camelCase for variables/functions
- Use PascalCase for classes
- Add documentation comments
- Keep functions focused and small

## Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/flutter)
- [Material Design](https://material.io)

## Next Steps

1. ✅ Project structure created
2. ✅ Models defined
3. ✅ Services implemented
4. ⏳ Implement Authentication screens
5. ⏳ Implement Database migrations
6. ⏳ Add real-time subscriptions
7. ⏳ Implement offline support
8. ⏳ Add unit tests
9. ⏳ Add integration tests
10. ⏳ Prepare for app store release

---
**Last Updated:** March 2026
**Version:** 1.0.0
