import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fund_app/core/constants/app_constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  late SupabaseClient _client;

  SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  Session? get currentSession => _client.auth.currentSession;

  User? get currentUser => _client.auth.currentUser;

  String? get userId => _client.auth.currentUser?.id;

  bool get isAuthenticated => _client.auth.currentSession != null;
}
