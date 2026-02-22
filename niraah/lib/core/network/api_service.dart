import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

import 'interceptors/openapi_logging_interceptor.dart';

class ApiService {
  ApiService._internal() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(
      OpenapiLoggingInterceptor(
        tokenProvider: _tokenProvider,
      ),
    );
    _apiClient = ApiClient(dio: dio, basePath: _baseUrl);
  }

  static const String _baseUrl = 'https://niraahwellness.com';
  static final ApiService _instance = ApiService._internal();

  static ApiService get instance => _instance;

  late final ApiClient _apiClient;

  static Future<String?> _tokenProvider() async {
    // Placeholder for secure token source integration.
    return null;
  }

  AuthenticationApi get authenticationApi => _apiClient.getAuthenticationApi();

  MemberApi get memberApi => _apiClient.getMemberApi();

  PlansApi get plansApi => _apiClient.getPlansApi();

  AdminApi get adminApi => _apiClient.getAdminApi();

  StorageApi get storageApi => _apiClient.getStorageApi();

  HealthApi get healthApi => _apiClient.getHealthApi();

  AIApi get aiApi => _apiClient.getAIApi();
}
