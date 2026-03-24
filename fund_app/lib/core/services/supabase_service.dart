import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/trip_model.dart';
import '../models/leave_tracking_model.dart';
import '../models/pool_balance_model.dart';
import '../models/pool_summary_model.dart';
import '../models/user_debts_model.dart';
import '../models/trip_summary_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  SupabaseClient get client => _client;

  Future<void> initialize(SupabaseClient client) async {
    _client = client;
  }

  // ===================== USER OPERATIONS =====================
  Future<UserModel?> getCurrentUser(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromMap(response);
    } catch (e) {
      print('Error fetching current user: $e');
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client
          .from('users')
          .select();
      return (response as List).map((data) => UserModel.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // ===================== TRANSACTION OPERATIONS =====================
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final response = await _client
          .from('transactions')
          .select()
          .order('date', ascending: false);
      return (response as List).map((data) => TransactionModel.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByMonth(DateTime month) async {
    try {
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final response = await _client
          .from('transactions')
          .select()
          .eq('month_key', monthKey)
          .order('date', ascending: false);
      return (response as List).map((data) => TransactionModel.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching transactions by month: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    try {
      final response = await _client
          .from('transactions')
          .select()
          .eq('type', type)
          .order('date', ascending: false);
      return (response as List).map((data) => TransactionModel.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching transactions by type: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByTrip(String tripId) async {
    try {
      final response = await _client
          .from('transactions')
          .select()
          .eq('trip_id', tripId)
          .order('date', ascending: false);
      return (response as List).map((data) => TransactionModel.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching transactions by trip: $e');
      return [];
    }
  }

  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      final response = await _client
          .from('transactions')
          .insert(transaction.toMap())
          .select()
          .single();
      return response['id'] as String;
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _client
          .from('transactions')
          .update(transaction.toMap())
          .eq('id', transaction.id);
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _client
          .from('transactions')
          .delete()
          .eq('id', transactionId);
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // ===================== TRIP OPERATIONS =====================
  Future<List<TripModel>> getAllTrips() async {
    try {
      final response = await _client
          .from('trips')
          .select()
          .order('start_date', ascending: false);
      return (response as List).map((data) => TripModel.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching trips: $e');
      return [];
    }
  }

  Future<TripModel?> getTrip(String tripId) async {
    try {
      final response = await _client
          .from('trips')
          .select()
          .eq('id', tripId)
          .single();
      return TripModel.fromMap(response);
    } catch (e) {
      print('Error fetching trip: $e');
      return null;
    }
  }

  Future<String> createTrip(TripModel trip) async {
    try {
      final response = await _client
          .from('trips')
          .insert(trip.toMap())
          .select()
          .single();
      return response['id'] as String;
    } catch (e) {
      print('Error creating trip: $e');
      rethrow;
    }
  }

  Future<void> updateTrip(TripModel trip) async {
    try {
      await _client
          .from('trips')
          .update(trip.toMap())
          .eq('id', trip.id);
    } catch (e) {
      print('Error updating trip: $e');
      rethrow;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _client
          .from('trips')
          .delete()
          .eq('id', tripId);
    } catch (e) {
      print('Error deleting trip: $e');
      rethrow;
    }
  }

  // ===================== LEAVE TRACKING OPERATIONS =====================
  Future<List<LeaveTrackingModel>> getLeaveTracking(String userId) async {
    try {
      final response = await _client
          .from('leave_tracking')
          .select()
          .eq('user_id', userId);
      return (response as List).map((data) => LeaveTrackingModel.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching leave tracking: $e');
      return [];
    }
  }

  Future<LeaveTrackingModel?> getLeaveTrackingByYear(String userId, int year) async {
    try {
      final response = await _client
          .from('leave_tracking')
          .select()
          .eq('user_id', userId)
          .eq('year', year)
          .single();
      return LeaveTrackingModel.fromMap(response);
    } catch (e) {
      print('Error fetching leave tracking by year: $e');
      return null;
    }
  }

  Future<void> updateLeaveTracking(LeaveTrackingModel leave) async {
    try {
      await _client
          .from('leave_tracking')
          .update(leave.toMap())
          .eq('id', leave.id);
    } catch (e) {
      print('Error updating leave tracking: $e');
      rethrow;
    }
  }

  // ===================== VIEW TABLE OPERATIONS =====================
  
  /// Fetch current pool balance
  Future<PoolBalanceModel?> getPoolBalance() async {
    try {
      final response = await _client
          .from('pool_balance')
          .select()
          .single();
      return PoolBalanceModel.fromMap(response);
    } catch (e) {
      print('Error fetching pool balance: $e');
      return null;
    }
  }

  /// Fetch pool summary for a specific month
  Future<PoolSummaryModel?> getPoolSummary(DateTime month) async {
    try {
      final response = await _client
          .from('pool_summary')
          .select()
          .eq('month', month.toIso8601String().split('T')[0]) // Date format
          .single();
      return PoolSummaryModel.fromMap(response);
    } catch (e) {
      print('Error fetching pool summary: $e');
      return null;
    }
  }

  /// Fetch debts for all users
  Future<List<UserDebtsModel>> getAllUserDebts() async {
    try {
      final response = await _client
          .from('user_debts')
          .select();
      return (response as List).map((data) => UserDebtsModel.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching user debts: $e');
      return [];
    }
  }

  /// Fetch debt for a specific user
  Future<UserDebtsModel?> getUserDebts(String userId) async {
    try {
      final response = await _client
          .from('user_debts')
          .select()
          .eq('user_id', userId)
          .single();
      return UserDebtsModel.fromMap(response);
    } catch (e) {
      print('Error fetching user debts: $e');
      return null;
    }
  }

  /// Fetch trip summary
  Future<List<TripSummaryModel>> getAllTripSummaries() async {
    try {
      final response = await _client
          .from('trip_summary')
          .select();
      return (response as List).map((data) => TripSummaryModel.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching trip summaries: $e');
      return [];
    }
  }

  /// Fetch trip summary for a specific trip
  Future<TripSummaryModel?> getTripSummary(String tripId) async {
    try {
      final response = await _client
          .from('trip_summary')
          .select()
          .eq('trip_id', tripId)
          .single();
      return TripSummaryModel.fromMap(response);
    } catch (e) {
      print('Error fetching trip summary: $e');
      return null;
    }
  }

  // ===================== REAL-TIME LISTENERS =====================
  
  /// Subscribe to transaction changes
  RealtimeChannel subscribeToTransactions(Function(TransactionModel) onTransactionChanged) {
    return _client
        .channel('transactions')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transactions',
          callback: (payload) {
            final transaction = TransactionModel.fromMap(payload.newRecord);
            onTransactionChanged(transaction);
          },
        )
        .subscribe();
  }

  /// Subscribe to trip changes
  RealtimeChannel subscribeToTrips(Function(TripModel) onTripChanged) {
    return _client
        .channel('trips')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'trips',
          callback: (payload) {
            final trip = TripModel.fromMap(payload.newRecord);
            onTripChanged(trip);
          },
        )
        .subscribe();
  }

  /// Subscribe to pool balance changes
  RealtimeChannel subscribeToPoolBalance(Function(PoolBalanceModel) onPoolBalanceChanged) {
    return _client
        .channel('pool_balance')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pool_balance',
          callback: (payload) {
            final poolBalance = PoolBalanceModel.fromMap(payload.newRecord);
            onPoolBalanceChanged(poolBalance);
          },
        )
        .subscribe();
  }

  /// Subscribe to user debts changes
  RealtimeChannel subscribeToUserDebts(Function(UserDebtsModel) onUserDebtsChanged) {
    return _client
        .channel('user_debts')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_debts',
          callback: (payload) {
            final userDebts = UserDebtsModel.fromMap(payload.newRecord);
            onUserDebtsChanged(userDebts);
          },
        )
        .subscribe();
  }
}
