import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';
import '../../transactions/domain/entities/transaction_entity.dart';

/// Use case to get home screen data
class GetHomeStateUseCase {
  final HomeRepository repository;

  GetHomeStateUseCase(this.repository);

  Future<HomeStateEntity> call(
    List<String> userIds,
    DateTime month,
  ) async {
    return repository.getHomeState(userIds, month);
  }
}

/// Use case to get pool balance
class GetPoolBalanceForHomeUseCase {
  final HomeRepository repository;

  GetPoolBalanceForHomeUseCase(this.repository);

  Future<double> call() async {
    return repository.getPoolBalance();
  }
}

/// Use case to get user debts
class GetUserDebtsUseCase {
  final HomeRepository repository;

  GetUserDebtsUseCase(this.repository);

  Future<Map<String, double>> call(List<String> userIds) async {
    return repository.getUserDebts(userIds);
  }
}

/// Use case to get recent transactions
class GetRecentTransactionsUseCase {
  final HomeRepository repository;

  GetRecentTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call({int limit = 10}) async {
    return repository.getRecentTransactions(limit: limit);
  }
}
