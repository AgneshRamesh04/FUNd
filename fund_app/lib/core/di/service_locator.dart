import 'package:get_it/get_it.dart';
import 'package:fund_app/core/services/supabase_service.dart';
import 'package:fund_app/core/services/auth_service.dart';
import 'package:fund_app/core/services/transaction_service.dart';
import 'package:fund_app/core/services/calculation_service.dart';
import 'package:fund_app/core/repositories/transaction_repository.dart';
import 'package:fund_app/core/repositories/user_repository.dart';
import 'package:fund_app/core/repositories/trip_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  final supabaseService = SupabaseService();
  getIt.registerSingleton(supabaseService);

  final authService = AuthService(supabaseService);
  getIt.registerSingleton(authService);

  final transactionService = TransactionService(supabaseService);
  getIt.registerSingleton(transactionService);

  final calculationService = CalculationService();
  getIt.registerSingleton(calculationService);

  // Repositories
  final transactionRepository = TransactionRepository(transactionService);
  getIt.registerSingleton(transactionRepository);

  final userRepository = UserRepository(supabaseService);
  getIt.registerSingleton(userRepository);

  final tripRepository = TripRepository(supabaseService);
  getIt.registerSingleton(tripRepository);
}
