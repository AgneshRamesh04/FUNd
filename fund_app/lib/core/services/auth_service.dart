import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  AuthService._internal();

  late final SupabaseClient _client;
  UserModel? _currentUser;

  void initialize(SupabaseClient client) {
    _client = client;
  }

  SupabaseClient get client => _client;
  UserModel? get currentUser => _currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;

  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      // Create user profile in database
      if (response.user != null) {
        await _client.from('users').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
          'monthly_obligation': 0.0,
        });
      }

      return response;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = await SupabaseService().getCurrentUser(response.user!.id);
      }

      return response;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _currentUser = null;
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  /// Get current user from database
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      if (currentUserId == null) return null;
      _currentUser = await SupabaseService().getCurrentUser(currentUserId!);
      return _currentUser;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  /// Listen to auth state changes
  void onAuthStateChange(Function(AuthState) callback) {
    _client.auth.onAuthStateChange.listen(callback);
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      print('Update password error: $e');
      rethrow;
    }
  }
}
