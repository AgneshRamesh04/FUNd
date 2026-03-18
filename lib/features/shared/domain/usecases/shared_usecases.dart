import '../entities/shared_entity.dart';
import '../repositories/shared_repository.dart';

/// Use case to get shared screen state
class GetSharedStateUseCase {
  final SharedRepository repository;

  GetSharedStateUseCase(this.repository);

  Future<SharedStateEntity> call(String userId) async {
    return repository.getSharedState(userId);
  }
}

/// Use case to get settlement with other user
class GetSettlementWithOtherUseCase {
  final SharedRepository repository;

  GetSettlementWithOtherUseCase(this.repository);

  Future<double> call(String userId, String otherId) async {
    return repository.getSettlementWithOther(userId, otherId);
  }
}
