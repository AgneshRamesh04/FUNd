// shared/providers/all_pool_members_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/app_user.dart';

final allPoolMembersProvider = FutureProvider<List<AppUser>>((ref) async {
  final data = await Supabase.instance.client
      .from('users')
      .select()
      .order('name');

  return (data as List)
      .map((u) => AppUser.fromJson(u as Map<String, dynamic>))
      .toList();
});
