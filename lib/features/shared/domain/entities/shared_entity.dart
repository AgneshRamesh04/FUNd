import 'package:equatable/equatable.dart';
import '../../transactions/domain/entities/transaction_entity.dart';

/// Shared screen state entity
class SharedStateEntity extends Equatable {
  final List<TransactionEntity> sharedExpenses;
  final double userTotalShare;
  final double userAlreadyPaid;
  final double userOwes;

  const SharedStateEntity({
    required this.sharedExpenses,
    required this.userTotalShare,
    required this.userAlreadyPaid,
    required this.userOwes,
  });

  @override
  List<Object?> get props => [
        sharedExpenses,
        userTotalShare,
        userAlreadyPaid,
        userOwes,
      ];
}
