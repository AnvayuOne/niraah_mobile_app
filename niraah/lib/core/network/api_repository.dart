import 'package:dio/dio.dart';

import '../../shared/helpers/result.dart';
import '../errors/api_exception.dart';

class ApiRepository {
  ApiRepository(this._dio);

  final Dio _dio;

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
  }) async {
    return _request(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
      parser,
    );
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
  }) async {
    return _request(
      () => _dio.post<dynamic>(path, data: data, queryParameters: queryParameters),
      parser,
    );
  }

  Future<Result<T>> _request<T>(
    Future<Response<dynamic>> Function() call,
    T Function(dynamic data) parser,
  ) async {
    try {
      final Response<dynamic> response = await call();
      final int statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException(message: 'Unexpected status code', statusCode: statusCode);
      }
      return Success<T>(parser(response.data));
    } on DioException catch (error) {
      return FailureResult<T>(
        error.response?.data?['message']?.toString() ?? error.message ?? 'Network request failed',
      );
    } on ApiException catch (error) {
      return FailureResult<T>(error.message);
    } catch (_) {
      return FailureResult<T>('Unknown request failure');
    }
  }
}
