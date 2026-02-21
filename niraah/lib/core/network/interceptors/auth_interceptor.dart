import 'package:dio/dio.dart';

typedef AccessTokenProvider = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenProvider);

  final AccessTokenProvider _tokenProvider;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final String? token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
