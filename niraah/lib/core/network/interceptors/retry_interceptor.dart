import 'dart:async';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 400),
  });

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  static const Set<String> _retryMethods = <String>{'GET', 'HEAD', 'OPTIONS'};

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final RequestOptions requestOptions = err.requestOptions;
    final String method = requestOptions.method.toUpperCase();
    final int retries = requestOptions.extra['retries'] as int? ?? 0;

    final bool shouldRetryType = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;
    final bool shouldRetry = shouldRetryType && _retryMethods.contains(method) && retries < maxRetries;

    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    requestOptions.extra['retries'] = retries + 1;
    final int nextAttempt = retries + 1;
    await Future<void>.delayed(baseDelay * nextAttempt);

    try {
      final Response<dynamic> response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
