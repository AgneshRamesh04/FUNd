import '../entities/personal_entity.dart';

/// Abstract repository for personal screen operations
abstract class PersonalRepository {
  /// Get personal screen state
  Future<PersonalStateEntity> getPersonalState(String userId);

  /// Get user's total borrowed
  Future<double> getTotalBorrowed(String userId);
}
