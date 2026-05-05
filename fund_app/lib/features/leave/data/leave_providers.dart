import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/home_providers.dart';
import 'leave_models.dart';
import 'leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository(ref.watch(supabaseClientProvider));
});

// ── Leave Entries State ───────────────────────────────────────────────────

class LeaveEntriesState {
  final List<LeaveEntry> entries;
  final bool isLoading;
  final String? error;

  const LeaveEntriesState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  LeaveEntriesState copyWith({
    List<LeaveEntry>? entries,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LeaveEntriesState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LeaveEntriesNotifier extends StateNotifier<LeaveEntriesState> {
  final LeaveRepository _repo;
  final String _userId;
  final int _year;

  LeaveEntriesNotifier(this._repo, this._userId, this._year)
      : super(const LeaveEntriesState()) {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final entries =
          await _repo.getLeaveEntriesByYear(_userId, _year);
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addEntry({
    required String description,
    required int daysUsed,
    required DateTime leaveDate,
    String? tripId,
  }) async {
    try {
      await _repo.createLeaveEntry(
        userId: _userId,
        description: description,
        daysUsed: daysUsed,
        leaveDate: leaveDate,
        tripId: tripId,
      );
      await _loadEntries();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _repo.deleteLeaveEntry(id);
      await _loadEntries();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final leaveEntriesByYearProvider = StateNotifierProvider.family<
    LeaveEntriesNotifier,
    LeaveEntriesState,
    (String userId, int year)>((ref, args) {
  final repo = ref.watch(leaveRepositoryProvider);
  return LeaveEntriesNotifier(repo, args.$1, args.$2);
});

// ── Leave Tracking State ──────────────────────────────────────────────────

final leaveTrackingProvider = FutureProvider.family<LeaveTracking?, (String userId, int year)>(
    (ref, args) async {
  final repo = ref.watch(leaveRepositoryProvider);
  try {
    return await repo.createOrGetLeaveTracking(args.$1, args.$2);
  } catch (e) {
    throw Exception('Failed to fetch leave tracking: $e');
  }
});

// ── Leave Tracking Mutation Provider ──────────────────────────────────────

class LeaveTrackingMutationNotifier extends StateNotifier<AsyncValue<void>> {
  final LeaveRepository _repo;

  LeaveTrackingMutationNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> updateTotal({
    required String userId,
    required int year,
    required int total,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.updateLeaveTrackingTotal(
        userId: userId,
        year: year,
        total: total,
      ),
    );

    if (state.hasError) {
      throw state.error!;
    }
  }
}

final leaveTrackingMutationProvider =
    StateNotifierProvider<LeaveTrackingMutationNotifier, AsyncValue<void>>(
        (ref) {
  final repo = ref.watch(leaveRepositoryProvider);
  return LeaveTrackingMutationNotifier(repo);
});

// ── All Leave Tracking for User ───────────────────────────────────────────

final allLeaveTrackingProvider =
    FutureProvider.family<List<LeaveTracking>, String>((ref, userId) async {
  final repo = ref.watch(leaveRepositoryProvider);
  return repo.getLeaveTrackingForUser(userId);
});

// ── Leave Summary ─────────────────────────────────────────────────────────

final leaveSummaryProvider = FutureProvider.family<LeaveSummary?, (String userId, int year)>(
    (ref, args) async {
  final repo = ref.watch(leaveRepositoryProvider);
  return repo.getLeaveSummary(args.$1, args.$2);
});

final allLeaveSummaryProvider =
    FutureProvider.family<List<LeaveSummary>, int>((ref, year) async {
  final repo = ref.watch(leaveRepositoryProvider);
  return repo.getAllLeaveSummary(year);
});
