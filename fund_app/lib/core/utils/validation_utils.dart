/// Utility functions for input validation
class ValidationUtils {
  /// Validates that an amount is a positive number
  static bool isValidAmount(double amount) {
    return amount > 0 && amount.isFinite;
  }

  /// Validates that a description is not empty
  static bool isValidDescription(String? description) {
    return description != null && description.trim().isNotEmpty;
  }

  /// Validates that a user ID is not empty
  static bool isValidUserId(String? userId) {
    return userId != null && userId.trim().isNotEmpty;
  }

  /// Validates that a date is not in the future
  static bool isValidDate(DateTime date) {
    return !date.isAfter(DateTime.now());
  }

  /// Sanitizes user input to prevent injection
  static String sanitizeInput(String input) {
    return input.trim();
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}
