import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'failure.dart';

class ErrorMapper {
  const ErrorMapper._();

  static Failure toFailure(Object error) {
    if (error is ApiException) {
      return ServerFailure(error.message);
    }
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return const NetworkFailure();
      }
      return ServerFailure(error.message ?? 'Unexpected network error');
    }
    return const UnknownFailure();
  }
}
