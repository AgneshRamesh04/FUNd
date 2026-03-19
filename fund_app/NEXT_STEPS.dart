/// NEXT STEPS - Integration Guide
/// 
/// This file explains what needs to be done to complete the app setup.
/// Follow the steps in order.

// ============================================================================
// STEP 1: Update Service Locator with Riverpod Providers
// ============================================================================
// File: lib/core/di/riverpod_providers.dart
// 
// Create Riverpod providers for services and repositories:
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fund_app/core/services/supabase_service.dart';
// import 'package:fund_app/core/repositories/transaction_repository.dart';
// import 'package:fund_app/core/services/calculation_service.dart';
//
// final supabaseServiceProvider = Provider((ref) {
//   return SupabaseService();
// });
//
// final transactionRepositoryProvider = Provider((ref) {
//   final supabaseService = ref.watch(supabaseServiceProvider);
//   return TransactionRepository(TransactionService(supabaseService));
// });
//
// final calculationServiceProvider = Provider((ref) {
//   return CalculationService();
// });

// ============================================================================
// STEP 2: Update Home Provider
// ============================================================================
// File: lib/features/home/providers/home_provider.dart
//
// Replace the TODO in homeProvider:
//
// final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
//   final transactionRepo = ref.watch(transactionRepositoryProvider);
//   final calcService = ref.watch(calculationServiceProvider);
//   return HomeNotifier(transactionRepo, calcService);
// });

// ============================================================================
// STEP 3: Connect Add Transaction Provider
// ============================================================================
// File: lib/features/transactions/providers/add_transaction_provider.dart
//
// Replace the TODO in addTransactionProvider:
//
// final addTransactionProvider = 
//     StateNotifierProvider<AddTransactionNotifier, AddTransactionState>((ref) {
//   final transactionRepo = ref.watch(transactionRepositoryProvider);
//   return AddTransactionNotifier(transactionRepo);
// });

// ============================================================================
// STEP 4: Connect Personal Screen to Real Data
// ============================================================================
// File: lib/features/personal/screens/personal_screen.dart
//
// Replace the empty transaction list with provider:
//
// class PersonalScreen extends ConsumerStatefulWidget {
//   ...
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final transactions = ref.watch(borrowTransactionsProvider);
//     
//     return Scaffold(...);
//   }
// }
//
// Create borrowTransactionsProvider:
//
// final borrowTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
//   final repo = ref.watch(transactionRepositoryProvider);
//   final transactions = await repo.getTransactions();
//   return transactions
//       .where((t) => t.type == TransactionType.borrow)
//       .toList();
// });

// ============================================================================
// STEP 5: Connect Shared Screen to Real Data
// ============================================================================
// File: lib/features/shared/screens/shared_screen.dart
//
// Create sharedExpensesProvider:
//
// final sharedExpensesProvider = FutureProvider<List<Transaction>>((ref) async {
//   final repo = ref.watch(transactionRepositoryProvider);
//   final transactions = await repo.getTransactions();
//   return transactions
//       .where((t) => t.type == TransactionType.sharedExpense)
//       .toList();
// });

// ============================================================================
// STEP 6: Implement Authentication Flow
// ============================================================================
// Create auth provider:
//
// final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
//   final authService = ref.watch(authServiceProvider);
//   return AuthNotifier(authService);
// });
//
// Create login and signup screens

// ============================================================================
// STEP 7: Run Code Generation
// ============================================================================
// Generate JSON serialization code:
//
// flutter pub run build_runner build

// ============================================================================
// STEP 8: Update Main and Add Auth Wrapper
// ============================================================================
// Wrap home screen with auth check:
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SupabaseService().initialize();
//   runApp(const ProviderScope(child: MyApp()));
// }
//
// Use FutureProvider to check auth status:
//
// final authStatusProvider = FutureProvider<bool>((ref) async {
//   final authService = ref.watch(authServiceProvider);
//   return authService.isAuthenticated;
// });

// ============================================================================
// Example: How to Access User ID in Features
// ============================================================================
// In any feature provider:
//
// // Get current user ID
// String? userId = SupabaseService().userId;
//
// // Or through Riverpod:
// final currentUserIdProvider = Provider((ref) {
//   return SupabaseService().userId;
// });

// ============================================================================
// Example: Real-time Updates
// ============================================================================
// To enable real-time updates in a provider:
//
// final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
//   final repo = ref.watch(transactionRepositoryProvider);
//   return repo.watchTransactions();
// });

// ============================================================================
// File Structure Checklist
// ============================================================================
//
// Core layer:
// ✓ lib/core/constants/app_constants.dart
// ✓ lib/core/theme/app_theme.dart
// ✓ lib/core/models/ (user, transaction, trip, leave_tracking)
// ✓ lib/core/services/ (supabase, auth, transaction, calculation)
// ✓ lib/core/repositories/ (transaction, user, trip)
// ✓ lib/core/di/service_locator.dart
// TODO lib/core/di/riverpod_providers.dart
//
// Features:
// ✓ lib/features/home/providers/home_provider.dart
// ✓ lib/features/home/screens/home_screen.dart
// ✓ lib/features/personal/screens/personal_screen.dart
// ✓ lib/features/shared/screens/shared_screen.dart
// ✓ lib/features/transactions/providers/add_transaction_provider.dart
// ✓ lib/features/transactions/screens/add_transaction_screen.dart
// TODO lib/features/auth/ (login, signup screens and provider)
//
// Root:
// ✓ lib/main.dart
// ✓ pubspec.yaml

// ============================================================================
// Quick Start after Setup
// ============================================================================
//
// 1. Create lib/core/di/riverpod_providers.dart with all providers
// 2. Update pubspec.yaml Supabase credentials in app_constants.dart
// 3. Run: flutter pub get
// 4. Run: flutter pub run build_runner build
// 5. Connect providers in home_provider.dart and add_transaction_provider.dart
// 6. Test: flutter run

// ============================================================================
// Debugging Tips
// ============================================================================
//
// - Use Riverpod DevTools: ref.refresh(homeProvider) to reload data
// - Check Supabase console for database errors
// - Use print() or debugPrint() for logging
// - Check Flutter DevTools for state changes
// - Enable Firebase/Supabase logging in Xcode/Android Studio
