import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // Supabase keys - LOAD FROM .env FILE
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // User identifiers
  static const String poolEntityId = 'pool';
  static const String poolEntityName = 'FUNd Pool';

  // Transaction defaults
  static const int defaultTransactionPageSize = 50;
  static const Duration realTimeSyncThrottle = Duration(milliseconds: 500);

  // Validation
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 999999.99;
  static const int minDescriptionLength = 1;
  static const int maxDescriptionLength = 500;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Performance
  static const Duration initialLoadTimeout = Duration(seconds: 2);
  static const Duration uiUpdateTimeout = Duration(milliseconds: 500);

  // Date & Time
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
}

/// App theme constants
class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color secondaryColor = Color(0xFF10B981);
  static const Color successColor = Color(0xFF34D399);
  static const Color warningColor = Color(0xFFFCD34D);
  static const Color errorColor = Color(0xFEF2F2F2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color textColorPrimary = Color(0xFF111827);
  static const Color textColorSecondary = Color(0xFF6B7280);
  static const Color textColorTertiary = Color(0xFF9CA3AF);

  // Typography
  static const double fontSizeXXL = 32;
  static const double fontSizeXL = 24;
  static const double fontSizeLarge = 20;
  static const double fontSizeBase = 16;
  static const double fontSizeSmall = 14;
  static const double fontSizeXSmall = 12;

  // Spacing
  static const double spacingXXL = 32.0;
  static const double spacingXL = 24.0;
  static const double spacingL = 16.0;
  static const double spacingM = 12.0;
  static const double spacingS = 8.0;
  static const double spacingXS = 4.0;

  // Border radius
  static const double radiusXL = 16.0;
  static const double radiusL = 12.0;
  static const double radiusM = 8.0;
  static const double radiusS = 4.0;
}

/// Application strings
class AppStrings {
  // Navigation
  static const String navHome = 'Home';
  static const String navPersonal = 'Personal';
  static const String navShared = 'Shared';

  // Buttons
  static const String btnAdd = 'Add';
  static const String btnSave = 'Save';
  static const String btnCancel = 'Cancel';
  static const String btnDelete = 'Delete';
  static const String btnEdit = 'Edit';
  static const String btnClose = 'Close';
  static const String btnConfirm = 'Confirm';

  // Home Screen
  static const String homeTitle = 'Financial Overview';
  static const String poolBalance = 'Pool Balance';
  static const String monthlyInflow = 'Monthly Inflow';
  static const String monthlyOutflow = 'Monthly Outflow';
  static const String moneyOwedToPool = 'Money Owed to Pool';
  static const String leaveTracking = 'Leave Tracking';

  // Personal Screen
  static const String personalTitle = 'Personal';
  static const String borrowFromFund = 'Borrow from FUNd';
  static const String addMoneyToFund = 'Add Money to FUNd';
  static const String noBorrows = 'No borrows yet';

  // Shared Screen
  static const String sharedTitle = 'Shared';
  static const String sharedExpenses = 'Shared Expenses';
  static const String noSharedExpenses = 'No shared expenses yet';

  // Transaction Form
  static const String txnFormAdd = 'Add Transaction';
  static const String txnFormEdit = 'Edit Transaction';
  static const String txnDescription = 'Description';
  static const String txnAmount = 'Amount';
  static const String txnDate = 'Date';
  static const String txnNotes = 'Notes';
  static const String txnPaidBy = 'Paid By';
  static const String txnReceivedBy = 'Received By';
  static const String txnType = 'Transaction Type';

  // Transaction Types
  static const String txnTypeBorrow = 'Borrow';
  static const String txnTypeDeposit = 'Deposit';
  static const String txnTypeSharedExpense = 'Shared Expense';
  static const String txnTypePoolExpense = 'Pool Expense';

  // Errors & Validation
  static const String errRequired = 'This field is required';
  static const String errInvalidAmount = 'Please enter a valid amount';
  static const String errAmountTooSmall = 'Amount must be at least 0.01';
  static const String errAmountTooLarge = 'Amount exceeds maximum limit';
  static const String errEmptyDescription = 'Description cannot be empty';

  // Success Messages
  static const String successAdded = 'Added successfully';
  static const String successUpdated = 'Updated successfully';
  static const String successDeleted = 'Deleted successfully';

  // Loading
  static const String loading = 'Loading...';
  static const String syncing = 'Syncing...';
}
