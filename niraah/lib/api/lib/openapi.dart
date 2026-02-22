library openapi;

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'src/api/admin_api.dart';
import 'src/api/ai_api.dart';
import 'src/api/authentication_api.dart';
import 'src/api/health_api.dart';
import 'src/api/member_api.dart';
import 'src/api/plans_api.dart';
import 'src/api/storage_api.dart';
import 'src/api_client.dart';

export 'src/api/admin_api.dart';
export 'src/api/ai_api.dart';
export 'src/api/authentication_api.dart';
export 'src/api/health_api.dart';
export 'src/api/member_api.dart';
export 'src/api/plans_api.dart';
export 'src/api/storage_api.dart';
export 'src/api_client.dart';
export 'src/model/admin_profile_get200_response.dart';
export 'src/model/admin_profile_get200_response_user.dart';
export 'src/model/admin_stats_get200_response.dart';
export 'src/model/admin_stats_get200_response_recent_members_inner.dart';
export 'src/model/ai_chat_post200_response.dart';
export 'src/model/ai_chat_post_request.dart';
export 'src/model/ai_chat_post_request_messages_inner.dart';
export 'src/model/appointment.dart';
export 'src/model/auth_login_password_post200_response.dart';
export 'src/model/auth_login_password_post_request.dart';
export 'src/model/auth_request_otp_post200_response.dart';
export 'src/model/auth_request_otp_post_request.dart';
export 'src/model/auth_verify_otp_post200_response.dart';
export 'src/model/auth_verify_otp_post_request.dart';
export 'src/model/date.dart';
export 'src/model/error.dart';
export 'src/model/health_get200_response.dart';
export 'src/model/member_ai_prescore_get200_response.dart';
export 'src/model/member_appointments_get200_response.dart';
export 'src/model/member_appointments_post200_response.dart';
export 'src/model/member_appointments_post_request.dart';
export 'src/model/member_profile_get200_response.dart';
export 'src/model/member_profile_get200_response_profile.dart';
export 'src/model/member_profile_get200_response_user.dart';
export 'src/model/member_profile_post200_response.dart';
export 'src/model/member_profile_post_request.dart';
export 'src/model/member_questionnaire_submit_post200_response.dart';
export 'src/model/member_questionnaire_submit_post200_response_scoring.dart';
export 'src/model/member_questionnaire_submit_post200_response_scoring_rule_score.dart';
export 'src/model/member_summary_get200_response.dart';
export 'src/model/member_symptoms_get200_response.dart';
export 'src/model/member_symptoms_post200_response.dart';
export 'src/model/member_symptoms_post_request.dart';
export 'src/model/member_tests_get200_response.dart';
export 'src/model/member_tests_get200_response_attachments_inner.dart';
export 'src/model/member_tests_get200_response_attachments_inner_uploader.dart';
export 'src/model/member_tests_post_request.dart';
export 'src/model/plan.dart';
export 'src/model/plans_get200_response.dart';
export 'src/model/plans_post200_response.dart';
export 'src/model/plans_post_request.dart';
export 'src/model/r2_presign_post200_response.dart';
export 'src/model/r2_presign_post_request.dart';
export 'src/model/symptom_entry.dart';
export 'src/model/symptom_entry_symptoms.dart';
export 'src/model/user.dart';
export 'src/serializers.dart';

class Openapi {
  Openapi({
    String basePath = 'https://niraahwellness.com',
    Dio? dio,
    Serializers? serializers,
  }) : apiClient = ApiClient(
          basePath: basePath,
          dio: dio,
          serializers: serializers,
        );

  final ApiClient apiClient;

  AIApi getAIApi() => apiClient.getAIApi();

  AdminApi getAdminApi() => apiClient.getAdminApi();

  AuthenticationApi getAuthenticationApi() => apiClient.getAuthenticationApi();

  HealthApi getHealthApi() => apiClient.getHealthApi();

  MemberApi getMemberApi() => apiClient.getMemberApi();

  PlansApi getPlansApi() => apiClient.getPlansApi();

  StorageApi getStorageApi() => apiClient.getStorageApi();
}
