// ignore_for_file: dangling_library_doc_comments

/// Enhanced logging utility for the application
/// 
/// Provides structured logging with different log levels and formatted output.
/// Use this instead of print() statements throughout the app.
/// 
/// Example:
/// ```dart
/// AppLogger.info('User logged in successfully');
/// AppLogger.error('Failed to fetch data', error: e, stackTrace: st);
/// ```
library;

import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static final Logger _loggerNoStack = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Log verbose/debug information
  /// 
  /// Use for detailed diagnostic information during development.
  static void debug(String message, {dynamic data}) {
    _loggerNoStack.d(message, error: data);
  }

  /// Log informational messages
  /// 
  /// Use for general informational messages about app state or flow.
  static void info(String message, {dynamic data}) {
    _loggerNoStack.i(message, error: data);
  }

  /// Log warning messages
  /// 
  /// Use for potentially harmful situations that should be reviewed.
  static void warning(String message, {dynamic data}) {
    _logger.w(message, error: data);
  }

  /// Log error messages with optional error object and stack trace
  /// 
  /// Use for error events that might still allow the app to continue running.
  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal error messages
  /// 
  /// Use for very severe error events that will presumably lead the app to abort.
  static void fatal(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log API requests
  /// 
  /// Specialized logging for HTTP requests and responses.
  static void apiRequest(String method, String url, {dynamic data}) {
    _loggerNoStack.i('API $method: $url', error: data);
  }

  /// Log API responses
  /// 
  /// Specialized logging for HTTP responses.
  static void apiResponse(int statusCode, String url, {dynamic data}) {
    if (statusCode >= 200 && statusCode < 300) {
      _loggerNoStack.i('API Response [$statusCode]: $url', error: data);
    } else if (statusCode >= 400) {
      _logger.e('API Error [$statusCode]: $url', error: data);
    } else {
      _loggerNoStack.w('API Response [$statusCode]: $url', error: data);
    }
  }
}
