import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

import '../../core/network/api_service.dart';
import '../../shared/helpers/result.dart';

class AuthRepository {
  AuthRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  Future<Result<AuthLoginPasswordPost200Response>> loginWithPassword(
    AuthLoginPasswordPostRequest request,
  ) async {
    try {
      final Response<AuthLoginPasswordPost200Response> response =
          await _apiService.authenticationApi.authLoginPasswordPost(
        authLoginPasswordPostRequest: request,
      );
      final AuthLoginPasswordPost200Response? body = response.data;
      if (body == null) {
        return const FailureResult<AuthLoginPasswordPost200Response>('Empty login response');
      }
      return Success<AuthLoginPasswordPost200Response>(body);
    } on DioException catch (error) {
      return FailureResult<AuthLoginPasswordPost200Response>(_errorMessage(error));
    } catch (_) {
      return const FailureResult<AuthLoginPasswordPost200Response>('Unexpected login failure');
    }
  }

  Future<Result<AuthRequestOtpPost200Response>> requestOtp(
    AuthRequestOtpPostRequest request,
  ) async {
    try {
      final Response<AuthRequestOtpPost200Response> response =
          await _apiService.authenticationApi.authRequestOtpPost(
        authRequestOtpPostRequest: request,
      );
      final AuthRequestOtpPost200Response? body = response.data;
      if (body == null) {
        return const FailureResult<AuthRequestOtpPost200Response>('Empty OTP response');
      }
      return Success<AuthRequestOtpPost200Response>(body);
    } on DioException catch (error) {
      return FailureResult<AuthRequestOtpPost200Response>(_errorMessage(error));
    } catch (_) {
      return const FailureResult<AuthRequestOtpPost200Response>('Unexpected OTP request failure');
    }
  }

  Future<Result<AuthVerifyOtpPost200Response>> verifyOtp(
    AuthVerifyOtpPostRequest request,
  ) async {
    try {
      final Response<AuthVerifyOtpPost200Response> response =
          await _apiService.authenticationApi.authVerifyOtpPost(
        authVerifyOtpPostRequest: request,
      );
      final AuthVerifyOtpPost200Response? body = response.data;
      if (body == null) {
        return const FailureResult<AuthVerifyOtpPost200Response>('Empty OTP verification response');
      }
      return Success<AuthVerifyOtpPost200Response>(body);
    } on DioException catch (error) {
      return FailureResult<AuthVerifyOtpPost200Response>(_errorMessage(error));
    } catch (_) {
      return const FailureResult<AuthVerifyOtpPost200Response>('Unexpected OTP verification failure');
    }
  }

  String _errorMessage(DioException error) {
    final dynamic data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final Object? message = data['message'] ?? data['error'];
      if (message != null) {
        return message.toString();
      }
    }
    return error.message ?? 'Network request failed';
  }
}
