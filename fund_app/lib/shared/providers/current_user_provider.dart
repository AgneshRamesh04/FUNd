// shared/providers/current_user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/app_user.dart';

final currentUserProvider = FutureProvider<AppUser>((ref) async {
  final user = Supabase.instance.client.auth.currentUser!;

  final data = await Supabase.instance.client
      .from('users')
      .select()
      .eq('id', user.id)
      .single();

  return AppUser.fromJson(data);
});
