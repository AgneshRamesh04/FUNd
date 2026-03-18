import 'package:equatable/equatable.dart';

/// User entity - domain layer
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, createdAt];
}

/// Auth response entity
class AuthResponseEntity extends Equatable {
  final UserEntity? user;
  final String? token;
  final String? error;
  final bool isSuccess;

  const AuthResponseEntity({
    this.user,
    this.token,
    this.error,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [user, token, error, isSuccess];
}
