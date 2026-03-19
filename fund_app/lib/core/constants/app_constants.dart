class AppConstants {
  // Supabase Config (replace with your values)
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Table Names
  static const String usersTable = 'users';
  static const String transactionsTable = 'transactions';
  static const String tripsTable = 'trips';
  static const String leaveTrackingTable = 'leave_tracking';

  // Pagination
  static const int pageSize = 20;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);

  // App Info
  static const String appName = 'FUNd';
  static const String appVersion = '1.0.0';
}
