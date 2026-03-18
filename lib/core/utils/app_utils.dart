import 'package:intl/intl.dart';

/// Date and time utilities
class DateUtils {
  /// Format date to string
  static String formatDate(DateTime date, [String format = 'dd MMM yyyy']) {
    return DateFormat(format).format(date);
  }

  /// Format date and time
  static String formatDateTime(
    DateTime date, [
    String format = 'dd MMM yyyy, hh:mm a',
  ]) {
    return DateFormat(format).format(date);
  }

  /// Get month name
  static String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get relative date string
  static String getRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }
}

/// Number and currency utilities
class NumberUtils {
  /// Format currency
  static String formatCurrency(double amount, [String symbol = '\$']) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Parse currency string
  static double parseCurrency(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }

  /// Format percentage
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  /// Round to 2 decimal places
  static double roundTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}

/// String utilities
class StringUtils {
  /// Capitalize first letter
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  /// Check if string is numeric
  static bool isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  /// Truncate string with ellipsis
  static String truncate(String value, {int length = 20}) {
    if (value.length <= length) return value;
    return '${value.substring(0, length)}...';
  }

  /// Convert to title case
  static String toTitleCase(String value) {
    return value
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
  }
}

/// Validation utilities
class ValidationUtils {
  /// Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate amount
  static bool isValidAmount(String amount) {
    try {
      final value = double.parse(amount);
      return value > 0;
    } catch (e) {
      return false;
    }
  }

  /// Validate password
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  /// Validate description
  static bool isValidDescription(String description) {
    return description.isNotEmpty && description.length <= 500;
  }
}
