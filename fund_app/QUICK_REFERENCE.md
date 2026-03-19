# FUNd App - Quick Reference Guide

## 🚀 Quick Start

### 1. Setup (5 minutes)
```bash
cd fund_app
flutter pub get
flutter pub run build_runner build
```

### 2. Configure Supabase
Update `lib/core/constants/app_constants.dart`:
```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
```

### 3. Create Database Tables
Run SQL queries in Supabase console (see IMPLEMENTATION_GUIDE.md)

### 4. Run App
```bash
flutter run
```

---

## 📁 File Locations - Quick Lookup

### Need to change...?

| Change | File |
|--------|------|
| App colors & spacing | `lib/core/theme/app_theme.dart` |
| App configuration | `lib/core/constants/app_constants.dart` |
| Home screen UI | `lib/features/home/screens/home_screen.dart` |
| Home business logic | `lib/features/home/providers/home_provider.dart` |
| Personal screen UI | `lib/features/personal/screens/personal_screen.dart` |
| Shared screen UI | `lib/features/shared/screens/shared_screen.dart` |
| Add transaction UI | `lib/features/transactions/screens/add_transaction_screen.dart` |
| Transaction logic | `lib/features/transactions/providers/add_transaction_provider.dart` |
| Calculation logic | `lib/core/services/calculation_service.dart` |
| Database interactions | `lib/core/services/transaction_service.dart` |
| Authentication | `lib/core/services/auth_service.dart` |
| App routing/navigation | `lib/main.dart` |

---

## 🧠 How It Works

### Data Flow Example: Getting Pool Balance

```
HomeScreen (UI)
    ↓ watches
homeProvider (Riverpod)
    ↓ calls
HomeNotifier._initialize()
    ↓ calls
transactionRepository.getTransactions()
    ↓ calls
TransactionService.getTransactions()
    ↓ calls
Supabase (Backend)
    ↓ returns transactions
HomeNotifier calculates using
calculationService.calculatePoolBalance()
    ↓ updates
HomeState with poolBalance
    ↓ triggers
HomeScreen rebuild with new poolBalance
```

### Adding a New Transaction

```
User taps FAB (+)
    ↓
AddTransactionScreen opens in modal
    ↓
User fills form and taps "Add Transaction"
    ↓
AddTransactionNotifier.submitTransaction()
    ↓
transactionRepository.createTransaction()
    ↓
Supabase creates in DB
    ↓
homeProvider auto-refreshes
    ↓ Home screen updates with new data
    ↓
Modal closes, success toast shown
```

---

## 🔧 Common Tasks

### Change App Name
```dart
// lib/core/constants/app_constants.dart
static const String appName = 'FUNd';

// lib/main.dart
return MaterialApp(
  title: 'FUNd',
  ...
);
```

### Add a New Color
```dart
// lib/core/theme/app_theme.dart
static const Color newColor = Color(0xFFHEXCODE);

// Use in widgets:
Text('Hello', style: TextStyle(color: AppTheme.newColor))
```

### Get Current User ID
```dart
// In any provider or service:
String? userId = SupabaseService().userId;

// Or in Riverpod:
final currentUser = ref.watch(currentUserIdProvider);
```

### Refresh Home Screen Data
```dart
// In a screen:
ref.refresh(homeProvider);
```

### Add a New Service
```dart
// 1. Create service in lib/core/services/
class MyService { ... }

// 2. Add to lib/core/di/riverpod_providers.dart
final myServiceProvider = Provider((ref) => MyService());

// 3. Use in feature:
final myService = ref.watch(myServiceProvider);
```

### Add a New Feature Screen
```
1. Create folder: lib/features/my_feature/
2. Create: lib/features/my_feature/screens/my_feature_screen.dart
3. Create: lib/features/my_feature/providers/my_feature_provider.dart (if needed)
4. Add to navigation in main.dart
```

---

## 📊 Transaction Types

| Type | From | To | Effect |
|------|------|----|----|
| **Borrow** | Pool | User | Pool ↓, User debt ↑ |
| **Deposit** | User | Pool | Pool ↑, User debt ↓ |
| **Shared Expense** | User A | Both | Split between users |
| **Pool Expense** | Pool | External | Pool ↓ |

---

## 🎯 Key Classes

### Models
- `User` - User info
- `Transaction` - Single transaction
- `Trip` - Trip grouping
- `LeaveTracking` - Leave balance

### Services
- `SupabaseService` - Backend client
- `AuthService` - Authentication
- `TransactionService` - API calls
- `CalculationService` - Math calculations

### Repositories
- `TransactionRepository` - Transaction data layer
- `UserRepository` - User data layer
- `TripRepository` - Trip data layer

---

## 🐛 Debugging

### Check what providers are available
```dart
// In any consumer widget:
// ref.watch([provider_name])
```

### View Supabase data directly
1. Go to Supabase dashboard
2. Open SQL Editor
3. Run queries to verify data

### See what's being calculated
```dart
// In calculation_service.dart, add:
print('Pool balance: $poolBalance');
```

### Check Riverpod state changes
- Use Riverpod DevTools extension in VS Code
- Or add print statements in providers

---

## 📱 UI Components

### Show Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
);
```

### Show Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Message')),
);
```

### Show Date Picker
```dart
final date = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime.now(),
);
```

### Show Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => MyWidget(),
);
```

---

## 🔐 Security Notes

- Never hardcode credentials
- Use Supabase Row Level Security (RLS)
- Validate all inputs
- Check auth before sensitive operations
- Use `.env` files for secrets (not in code)

---

## 📚 Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev)
- [Supabase Docs](https://supabase.com/docs)
- [Material Design](https://material.io/design)
- [Dart Docs](https://dart.dev/guides)

---

## ⚡ Performance Tips

- Use `FutureProvider` for one-time fetches
- Use `StreamProvider` for real-time data
- Paginate long lists (set `limit` in queries)
- Use `.family` providers for parameterized queries
- Refresh only when needed (`ref.refresh()`)

---

## 📝 Common Patterns

### Watching multiple providers
```dart
final data1 = ref.watch(provider1);
final data2 = ref.watch(provider2);
```

### Conditional rendering
```dart
if (state.isLoading) {
  return CircularProgressIndicator();
} else if (state.error != null) {
  return Text('Error: ${state.error}');
} else {
  return MyContent();
}
```

### Pull-to-refresh
```dart
RefreshIndicator(
  onRefresh: () => ref.refresh(homeProvider).future,
  child: ListView(...),
)
```

---

## 🎨 Theme Customization

All theme values are in `lib/core/theme/app_theme.dart`:
- Colors: `AppTheme.primaryColor`, `AppTheme.errorColor`, etc.
- Text: `AppTheme.headlineLarge`, `AppTheme.bodyMedium`, etc.
- Spacing: `AppTheme.spacing8`, `AppTheme.spacing16`, etc.
- Border radius: `AppTheme.radiusSmall`, `AppTheme.radiusLarge`, etc.

---

## 💡 Pro Tips

1. **Use const constructors** for better performance
2. **Extract widgets into separate files** for reusability
3. **Use meaningful variable names** for readability
4. **Comment complex logic** for future maintenance
5. **Test on both iOS and Android** regularly
6. **Use hot reload frequently** during development
7. **Keep providers focused** (single responsibility)
8. **Validate user input** before sending to backend

---

## 🚨 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Providers not working | Import `riverpod_providers.dart` |
| JSON serialization errors | Run `flutter pub run build_runner build` |
| Supabase connection errors | Check URL and API key in constants |
| Real-time not updating | Check Supabase replication settings |
| Null exceptions | Add proper null checks and error handling |

---

## 📞 Support

Refer to:
- `IMPLEMENTATION_GUIDE.md` - Detailed setup
- `NEXT_STEPS.dart` - Integration steps
- `FILE_SUMMARY.md` - Complete file listing
- Inline code comments for specific implementations

---

**Happy coding! 🎉**
