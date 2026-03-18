import 'package:equatable/equatable.dart';
import '../../transactions/domain/entities/transaction_entity.dart';

/// Personal screen state entity
class PersonalStateEntity extends Equatable {
  final List<TransactionEntity> borrows;
  final double totalBorrowed;
  final double userDebt;

  const PersonalStateEntity({
    required this.borrows,
    required this.totalBorrowed,
    required this.userDebt,
  });

  @override
  List<Object?> get props => [borrows, totalBorrowed, userDebt];
}
