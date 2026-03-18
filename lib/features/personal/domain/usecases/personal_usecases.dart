import '../entities/personal_entity.dart';
import '../repositories/personal_repository.dart';

/// Use case to get personal screen state
class GetPersonalStateUseCase {
  final PersonalRepository repository;

  GetPersonalStateUseCase(this.repository);

  Future<PersonalStateEntity> call(String userId) async {
    return repository.getPersonalState(userId);
  }
}

/// Use case to get total borrowed
class GetTotalBorrowedUseCase {
  final PersonalRepository repository;

  GetTotalBorrowedUseCase(this.repository);

  Future<double> call(String userId) async {
    return repository.getTotalBorrowed(userId);
  }
}
