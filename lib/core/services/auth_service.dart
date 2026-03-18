import '../database/models.dart';
import 'supabase_service.dart';

/// Authentication service
class AuthService {
  final SupabaseService _supabaseService;

  AuthService(this._supabaseService);

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _supabaseService.isAuthenticated();
  }

  /// Get current user
  User? getCurrentUser() {
    return _supabaseService.getCurrentUser();
  }

  /// Sign up a new user
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        name: name,
      );
      
      if (response.user != null) {
        return getCurrentUser();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabaseService.signIn(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Validate sign up inputs
  String? validateSignUpInputs({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) {
    if (name.isEmpty) {
      return 'Name cannot be empty';
    }
    
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }
    
    if (!email.contains('@')) {
      return 'Invalid email format';
    }
    
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validate sign in inputs
  String? validateSignInInputs({
    required String email,
    required String password,
  }) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }
    
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    
    return null;
  }
}
