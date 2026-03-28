import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_repository.dart';
import 'home_models.dart';

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final homeRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return HomeRepository(client);
});

final poolBalanceProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchPoolBalance();
});

final userDebtsProvider = FutureProvider<List<UserDebt>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchUserDebts();
});

/// Keyed by year — re-fetches automatically when the selected year changes.
final userLeavesProvider =
    FutureProvider.family<List<UserLeave>, int>((ref, year) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchUserLeaves(year);
});

final inflowOutflowProvider =
    FutureProvider.family<Map<String, double>, DateTime>((ref, month) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchMonthlyInflowOutflow(month);
});
