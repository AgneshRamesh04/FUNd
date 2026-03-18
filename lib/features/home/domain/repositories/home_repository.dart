import '../../transactions/domain/entities/transaction_entity.dart';
import '../entities/home_entity.dart';

/// Abstract repository for home screen operations
abstract class HomeRepository {
  /// Get home screen data
  Future<HomeStateEntity> getHomeState(
    List<String> userIds,
    DateTime month,
  );

  /// Get pool balance
  Future<double> getPoolBalance();

  /// Get user debts
  Future<Map<String, double>> getUserDebts(List<String> userIds);

  /// Get recent transactions
  Future<List<TransactionEntity>> getRecentTransactions({int limit = 10});
}
