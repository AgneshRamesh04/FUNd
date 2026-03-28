import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (optional for development)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env file is not required for release builds
    // Environment variables can be configured via build args or system env
    debugPrint('Note: .env file not found. Falling back to system environment variables.');
  }

  // Safely retrieve environment variables with fallbacks
  String supabaseUrl = '';
  String supabaseAnonKey = '';
  
  try {
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 
        const String.fromEnvironment('SUPABASE_URL');
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 
        const String.fromEnvironment('SUPABASE_ANON_KEY');

    debugPrint("--- ${supabaseUrl} \n--- ${supabaseAnonKey}");
  } catch (e) {
    // If dotenv is not initialized, try const from environment
    debugPrint("\n\n--- i am not where i wanna be\n\n");
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
  }

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY. '
      'Set them in .env file (dev) or via --dart-define build flags (production).',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}
