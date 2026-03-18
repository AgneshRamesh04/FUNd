import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/models.dart';

/// Service for Supabase integration
/// Handles all backend communication and real-time subscriptions
class SupabaseService {
  late SupabaseClient _client;
  
  static const String usersTable = 'users';
  static const String transactionsTable = 'transactions';
  static const String tripsTable = 'trips';
  static const String leaveTable = 'leave_tracking';

  /// Initialize Supabase
  /// Must be called before using any Supabase methods
  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get initialized Supabase client
  SupabaseClient get client => _client;

  /// Get current authenticated user
  User? getCurrentUser() {
    final authUser = _client.auth.currentUser;
    if (authUser != null) {
      return User(
        id: authUser.id,
        name: authUser.userMetadata?['name'] ?? 'User',
        email: authUser.email ?? '',
        createdAt: authUser.createdAt,
      );
    }
    return null;
  }

  /// Sign up a new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  /// Sign in user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Fetch all users
  Future<List<User>> fetchUsers() async {
    try {
      final data = await _client
          .from(usersTable)
          .select()
          .order('created_at', ascending: false);
      
      return (data as List)
          .map((user) => User.fromJson(user as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch transactions
  Future<List<Transaction>> fetchTransactions({
    String? tripId,
  }) async {
    try {
      var query = _client
          .from(transactionsTable)
          .select();
      
      if (tripId != null) {
        query = query.eq('trip_id', tripId);
      }
      
      final data = await query.order('date', ascending: false);
      
      return (data as List)
          .map((tx) => Transaction.fromJson(tx as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new transaction
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final data = await _client
          .from(transactionsTable)
          .insert(transaction.toJson())
          .select()
          .single();
      
      return Transaction.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing transaction
  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      final data = await _client
          .from(transactionsTable)
          .update(transaction.toJson())
          .eq('id', transaction.id)
          .select()
          .single();
      
      return Transaction.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _client
          .from(transactionsTable)
          .delete()
          .eq('id', transactionId);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch trips
  Future<List<Trip>> fetchTrips() async {
    try {
      final data = await _client
          .from(tripsTable)
          .select()
          .order('start_date', ascending: false);
      
      return (data as List)
          .map((trip) => Trip.fromJson(trip as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new trip
  Future<Trip> createTrip(Trip trip) async {
    try {
      final data = await _client
          .from(tripsTable)
          .insert(trip.toJson())
          .select()
          .single();
      
      return Trip.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch leave tracking data
  Future<List<LeaveTracking>> fetchLeaveTracking(String userId) async {
    try {
      final data = await _client
          .from(leaveTable)
          .select()
          .eq('user_id', userId);
      
      return (data as List)
          .map((leave) => LeaveTracking.fromJson(leave as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Subscribe to real-time transaction updates
  RealtimeChannel subscribeToTransactions() {
    return _client
        .channel('transactions:channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: transactionsTable,
          callback: (payload) {
            // Handle real-time updates
          },
        )
        .subscribe();
  }

  /// Subscribe to real-time trip updates
  RealtimeChannel subscribeToTrips() {
    return _client
        .channel('trips:channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: tripsTable,
          callback: (payload) {
            // Handle real-time updates
          },
        )
        .subscribe();
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }
}
