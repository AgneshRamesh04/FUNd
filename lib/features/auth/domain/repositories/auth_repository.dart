import '../entities/user_entity.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Sign up a new user
  Future<AuthResponseEntity> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Sign in user
  Future<AuthResponseEntity> signIn({
    required String email,
    required String password,
  });

  /// Sign out user
  Future<void> signOut();

  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Refresh authentication token
  Future<String?> refreshToken();
}
