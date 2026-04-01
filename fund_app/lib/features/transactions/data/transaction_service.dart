import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../personal/data/personal_providers.dart';
import '../../personal/data/personal_repository.dart';
import '../../shared_expenses/data/shared_expenses_providers.dart';
import '../../shared_expenses/data/shared_expenses_repository.dart';

class TransactionService {
  final PersonalRepository _personalRepository;
  final SharedExpensesRepository _sharedRepository;

  TransactionService(this._personalRepository, this._sharedRepository);

  Future<void> createPersonalExpense({
    required String userId,
    required double amount,
    required String description,
    required DateTime date,
    required String monthKey,
    String? notes,
  }) async {
    // Additional business logic can be placed here.
    await _personalRepository.createPersonalTransaction(
      userId: userId,
      amount: amount,
      description: description,
      date: date,
      monthKey: monthKey,
      notes: notes,
    );
  }

  Future<void> createSharedExpense({
    required bool isFundPool,
    required String? userId,
    required double amount,
    required String description,
    required DateTime date,
    required String monthKey,
    String? notes,
  }) async {
    final resolvedUserId = isFundPool ? null : userId;
    await _sharedRepository.createTransaction(
      type: 'shared',
      userId: resolvedUserId,
      amount: amount,
      description: description,
      date: date,
      monthKey: monthKey,
      notes: notes,
    );
  }

  Future<void> createDeposit({
    required String userId,
    required double amount,
    required String description,
    required DateTime date,
    required String monthKey,
    String? notes,
  }) async {
    await _sharedRepository.createTransaction(
      type: 'deposit',
      userId: userId,
      amount: amount,
      description: description,
      date: date,
      monthKey: monthKey,
      notes: notes,
    );
  }

  Future<void> createTrip({
    required String tripName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _sharedRepository.createTrip(
      tripName: tripName,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> updatePersonalTransaction({
    required String id,
    required String userId,
    required String type,
    required double amount,
    required String description,
    required DateTime date,
    required String monthKey,
    String? notes,
  }) async {
    await _personalRepository.updatePersonalTransaction(
      id: id,
      userId: userId,
      type: type,
      amount: amount,
      description: description,
      date: date,
      monthKey: monthKey,
      notes: notes,
    );
  }

  Future<void> deletePersonalTransaction(String id) async {
    await _personalRepository.deletePersonalTransaction(id);
  }

  Future<void> updateSharedTransaction({
    required String id,
    required String type,
    required String? userId,
    required double amount,
    required String description,
    required DateTime date,
    required String monthKey,
    String? notes,
  }) async {
    await _sharedRepository.updateTransaction(
      id: id,
      type: type,
      userId: userId,
      amount: amount,
      description: description,
      date: date,
      monthKey: monthKey,
      notes: notes,
    );
  }

  Future<void> deleteSharedTransaction(String id) async {
    await _sharedRepository.deleteTransaction(id);
  }
}

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final personalRepo = ref.watch(personalRepositoryProvider);
  final sharedRepo = ref.watch(sharedExpensesRepositoryProvider);
  return TransactionService(personalRepo, sharedRepo);
});
