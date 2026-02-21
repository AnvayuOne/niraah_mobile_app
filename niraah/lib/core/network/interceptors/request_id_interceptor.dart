import 'dart:math';

import 'package:dio/dio.dart';

class RequestIdInterceptor extends Interceptor {
  final Random _random = Random();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Request-Id'] = _requestId();
    handler.next(options);
  }

  String _requestId() {
    final int now = DateTime.now().microsecondsSinceEpoch;
    final int entropy = _random.nextInt(1 << 20);
    return '$now-$entropy';
  }
}
