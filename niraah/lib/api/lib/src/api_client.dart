import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'api/admin_api.dart';
import 'api/ai_api.dart';
import 'api/authentication_api.dart';
import 'api/health_api.dart';
import 'api/member_api.dart';
import 'api/plans_api.dart';
import 'api/storage_api.dart';
import 'serializers.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    String basePath = 'https://niraahwellness.com',
    Serializers? serializers,
  })  : dio = dio ?? Dio(BaseOptions(baseUrl: basePath)),
        serializers = serializers ?? OpenapiSerializers.serializers {
    this.dio.options.baseUrl = basePath;
  }

  final Dio dio;
  final Serializers serializers;

  AIApi getAIApi() => AIApi(dio, serializers);

  AdminApi getAdminApi() => AdminApi(dio, serializers);

  AuthenticationApi getAuthenticationApi() => AuthenticationApi(dio, serializers);

  HealthApi getHealthApi() => HealthApi(dio, serializers);

  MemberApi getMemberApi() => MemberApi(dio, serializers);

  PlansApi getPlansApi() => PlansApi(dio, serializers);

  StorageApi getStorageApi() => StorageApi(dio, serializers);
}
