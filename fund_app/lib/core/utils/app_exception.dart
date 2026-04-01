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

  /// Gets a user-friendly error message based on error code
  String getUserFriendlyMessage() {
    return switch (code) {
      'db_error' => 'Database error. Please try again.',
      'network_error' => 'Network error. Check your connection.',
      'timeout_error' => 'Request timed out. Please try again.',
      'auth_error' => 'Authentication failed. Please log in again.',
      'validation_error' => message, // Already user-friendly
      'not_found_error' => 'The requested item was not found.',
      'permission_error' => 'You do not have permission to perform this action.',
      'conflict_error' => 'This operation conflicts with existing data.',
      _ => message,
    };
  }

  /// Converts database or network errors to user-friendly messages with proper error codes
  factory AppException.fromError(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    String message = 'An unexpected error occurred';
    String? code;
    final errorStr = error.toString();

    if (errorStr.contains('PgSQLException')) {
      message = 'Database error. Please try again.';
      code = 'db_error';
    } 
    else if (errorStr.contains('SocketException')) {
      message = 'Network error. Check your connection.';
      code = 'network_error';
    } 
    else if (errorStr.contains('TimeoutException')) {
      message = 'Request timed out. Please try again.';
      code = 'timeout_error';
    } 
    else if (errorStr.contains('AuthException')) {
      message = 'Authentication failed. Please log in again.';
      code = 'auth_error';
    }
    else if (errorStr.contains('not found') || errorStr.contains('404')) {
      message = 'The requested item was not found.';
      code = 'not_found_error';
    }
    else if (errorStr.contains('permission') || errorStr.contains('403')) {
      message = 'You do not have permission to perform this action.';
      code = 'permission_error';
    }
    else if (errorStr.contains('conflict') || errorStr.contains('409')) {
      message = 'This operation conflicts with existing data.';
      code = 'conflict_error';
    }

    return AppException(
      message: message,
      code: code,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Creates a validation error
  factory AppException.validation(String message) {
    return AppException(
      message: message,
      code: 'validation_error',
    );
  }

  /// Creates a not found error
  factory AppException.notFound(String message) {
    return AppException(
      message: message,
      code: 'not_found_error',
    );
  }

  /// Creates a permission error
  factory AppException.permission(String message) {
    return AppException(
      message: message,
      code: 'permission_error',
    );
  }
}
