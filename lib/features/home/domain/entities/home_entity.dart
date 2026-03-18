import 'package:equatable/equatable.dart';
import '../../transactions/domain/entities/transaction_entity.dart';

/// Home screen state entity
class HomeStateEntity extends Equatable {
  final double poolBalance;
  final MonthlySummaryEntity monthlySummary;
  final Map<String, double> userDebts;
  final List<TransactionEntity> recentTransactions;

  const HomeStateEntity({
    required this.poolBalance,
    required this.monthlySummary,
    required this.userDebts,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        poolBalance,
        monthlySummary,
        userDebts,
        recentTransactions,
      ];
}
