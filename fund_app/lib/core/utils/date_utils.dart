/// Utility functions for date and time operations
class DateUtils {
  /// Converts DateTime to month key format: 'YYYY-MM-01'
  static String toMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-01';
  }

  /// Converts DateTime to date string format: 'YYYY-MM-DD'
  static String toDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Gets the first day of the next month
  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }

  /// Gets the last day of the month
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1).subtract(const Duration(days: 1));
  }

  /// Normalizes a date to start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Parses month key back to DateTime
  static DateTime parseMonthKey(String monthKey) {
    // monthKey format: 'YYYY-MM-01' or 'YYYY-MM-DD'
    final parts = monthKey.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
  }
}
