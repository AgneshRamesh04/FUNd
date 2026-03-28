/// Application-level exception for consistent error handling
class AppException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;

  /// Converts database or network errors to user-friendly messages
  factory AppException.fromError(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    String message = 'An unexpected error occurred';
    String? code;

    if (error.toString().contains('PgSQLException')) {
      message = 'Database error. Please try again.';
      code = 'db_error';
    } else if (error.toString().contains('SocketException')) {
      message = 'Network error. Check your connection.';
      code = 'network_error';
    } else if (error.toString().contains('TimeoutException')) {
      message = 'Request timed out. Please try again.';
      code = 'timeout_error';
    } else if (error.toString().contains('AuthException')) {
      message = 'Authentication failed. Please log in again.';
      code = 'auth_error';
    }

    return AppException(
      message: message,
      code: code,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
