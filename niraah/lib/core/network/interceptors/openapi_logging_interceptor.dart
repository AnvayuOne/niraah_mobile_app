import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';

typedef OpenapiAccessTokenProvider = Future<String?> Function();

class OpenapiLoggingInterceptor extends Interceptor {
  OpenapiLoggingInterceptor({required OpenapiAccessTokenProvider tokenProvider})
      : _tokenProvider = tokenProvider;

  final OpenapiAccessTokenProvider _tokenProvider;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final String? token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    AppLogger.logRequest(
      method: options.method,
      path: options.path,
      headers: options.headers,
      body: options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    AppLogger.logResponse(
      statusCode: response.statusCode,
      path: response.requestOptions.path,
      body: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.logError(
      'OpenAPI request failed: ${err.requestOptions.method} ${err.requestOptions.path}',
      error: err.error ?? err.message,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
