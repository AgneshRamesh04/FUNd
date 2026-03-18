import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user sign up
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AuthResponseEntity> call({
    required String email,
    required String password,
    required String name,
  }) async {
    return repository.signUp(
      email: email,
      password: password,
      name: name,
    );
  }
}

/// Use case for user sign in
class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<AuthResponseEntity> call({
    required String email,
    required String password,
  }) async {
    return repository.signIn(
      email: email,
      password: password,
    );
  }
}

/// Use case for user sign out
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() async {
    return repository.signOut();
  }
}

/// Use case to get current user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() async {
    return repository.getCurrentUser();
  }
}

/// Use case to check if authenticated
class IsAuthenticatedUseCase {
  final AuthRepository repository;

  IsAuthenticatedUseCase(this.repository);

  Future<bool> call() async {
    return repository.isAuthenticated();
  }
}
