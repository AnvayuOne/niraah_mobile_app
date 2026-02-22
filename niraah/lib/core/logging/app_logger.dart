import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void logInfo(String message) {
    debugPrint('[INFO] $message');
  }

  static void logError(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('[ERROR] details: $error');
    }
    if (stackTrace != null) {
      debugPrint('[ERROR] stack: $stackTrace');
    }
  }

  static void logRequest({
    required String method,
    required String path,
    Object? headers,
    Object? body,
  }) {
    debugPrint('[REQUEST] $method $path');
    debugPrint('[REQUEST] headers: $headers');
    debugPrint('[REQUEST] body: $body');
  }

  static void logResponse({
    required int? statusCode,
    required String path,
    Object? body,
  }) {
    debugPrint('[RESPONSE] $statusCode $path');
    debugPrint('[RESPONSE] body: $body');
  }
}
