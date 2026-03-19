import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService;

  AuthService(this._supabaseService);

  SupabaseClient get _client => _supabaseService.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      return await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Stream<AuthState> get authStateChange => _client.auth.onAuthStateChange;

  bool get isAuthenticated => _supabaseService.isAuthenticated;

  String? get currentUserId => _supabaseService.userId;

  User? get currentUser => _supabaseService.currentUser;
}
