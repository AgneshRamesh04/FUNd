import '../entities/shared_entity.dart';

/// Abstract repository for shared screen operations
abstract class SharedRepository {
  /// Get shared screen state
  Future<SharedStateEntity> getSharedState(String userId);

  /// Get settlement amount between two users
  Future<double> getSettlementWithOther(String userId, String otherId);
}
