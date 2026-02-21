import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../shared/constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/request_id_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  DioClient({required AccessTokenProvider tokenProvider}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.connectTimeout,
        headers: <String, Object>{'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.addAll(<Interceptor>[
      RequestIdInterceptor(),
      AuthInterceptor(tokenProvider),
      RetryInterceptor(_dio),
      if (kDebugMode) PrettyDioLogger(requestBody: true, requestHeader: true),
    ]);
  }

  late final Dio _dio;

  Dio get instance => _dio;
}
