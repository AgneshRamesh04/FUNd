import 'package:fund_app/core/models/user_model.dart';
import 'package:fund_app/core/services/supabase_service.dart';
import 'package:fund_app/core/constants/app_constants.dart';

class UserRepository {
  final SupabaseService _supabaseService;

  UserRepository(this._supabaseService);

  Future<User> createUser({
    required String id,
    required String name,
    required String email,
  }) async {
    final now = DateTime.now();
    final data = {
      'id': id,
      'name': name,
      'email': email,
      'created_at': now.toIso8601String(),
    };

    final response = await _supabaseService.client
        .from(AppConstants.usersTable)
        .insert(data)
        .select()
        .single();

    return User.fromJson(response);
  }

  Future<User?> getUser(String userId) async {
    try {
      final response = await _supabaseService.client
          .from(AppConstants.usersTable)
          .select()
          .eq('id', userId)
          .single();

      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<User>> getAllUsers() async {
    final response = await _supabaseService.client
        .from(AppConstants.usersTable)
        .select();

    return (response as List)
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<User> updateUser({
    required String userId,
    String? name,
    String? email,
  }) async {
    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (email != null) updateData['email'] = email;

    final response = await _supabaseService.client
        .from(AppConstants.usersTable)
        .update(updateData)
        .eq('id', userId)
        .select()
        .single();

    return User.fromJson(response);
  }
}
