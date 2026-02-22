import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'model/admin_profile_get200_response.dart';
import 'model/admin_profile_get200_response_user.dart';
import 'model/admin_stats_get200_response.dart';
import 'model/admin_stats_get200_response_recent_members_inner.dart';
import 'model/ai_chat_post200_response.dart';
import 'model/ai_chat_post_request.dart';
import 'model/ai_chat_post_request_messages_inner.dart';
import 'model/appointment.dart';
import 'model/auth_login_password_post200_response.dart';
import 'model/auth_login_password_post_request.dart';
import 'model/auth_request_otp_post200_response.dart';
import 'model/auth_request_otp_post_request.dart';
import 'model/auth_verify_otp_post200_response.dart';
import 'model/auth_verify_otp_post_request.dart';
import 'model/date.dart';
import 'model/error.dart';
import 'model/health_get200_response.dart';
import 'model/member_ai_prescore_get200_response.dart';
import 'model/member_appointments_get200_response.dart';
import 'model/member_appointments_post200_response.dart';
import 'model/member_appointments_post_request.dart';
import 'model/member_profile_get200_response.dart';
import 'model/member_profile_get200_response_profile.dart';
import 'model/member_profile_get200_response_user.dart';
import 'model/member_profile_post200_response.dart';
import 'model/member_profile_post_request.dart';
import 'model/member_questionnaire_submit_post200_response.dart';
import 'model/member_questionnaire_submit_post200_response_scoring.dart';
import 'model/member_questionnaire_submit_post200_response_scoring_rule_score.dart';
import 'model/member_summary_get200_response.dart';
import 'model/member_symptoms_get200_response.dart';
import 'model/member_symptoms_post200_response.dart';
import 'model/member_symptoms_post_request.dart';
import 'model/member_tests_get200_response.dart';
import 'model/member_tests_get200_response_attachments_inner.dart';
import 'model/member_tests_get200_response_attachments_inner_uploader.dart';
import 'model/member_tests_post_request.dart';
import 'model/plan.dart';
import 'model/plans_get200_response.dart';
import 'model/plans_post200_response.dart';
import 'model/plans_post_request.dart';
import 'model/r2_presign_post200_response.dart';
import 'model/r2_presign_post_request.dart';
import 'model/symptom_entry.dart';
import 'model/symptom_entry_symptoms.dart';
import 'model/user.dart';

class OpenapiSerializers {
  const OpenapiSerializers._();

  static final Serializers serializers = (_serializers.toBuilder()
        ..add(Date.serializer)
        ..addBuilderFactory(
          const FullType(BuiltList, <FullType>[FullType(String)]),
          () => ListBuilder<String>(),
        )
        ..addBuilderFactory(
          const FullType(BuiltList, <FullType>[FullType(Plan)]),
          () => ListBuilder<Plan>(),
        )
        ..addBuilderFactory(
          const FullType(BuiltList, <FullType>[FullType(Appointment)]),
          () => ListBuilder<Appointment>(),
        )
        ..addBuilderFactory(
          const FullType(
            BuiltList,
            <FullType>[FullType(MemberTestsGet200ResponseAttachmentsInner)],
          ),
          () => ListBuilder<MemberTestsGet200ResponseAttachmentsInner>(),
        )
        ..addBuilderFactory(
          const FullType(BuiltList, <FullType>[FullType(SymptomEntry)]),
          () => ListBuilder<SymptomEntry>(),
        )
        ..addBuilderFactory(
          const FullType(
            BuiltList,
            <FullType>[FullType(AiChatPostRequestMessagesInner)],
          ),
          () => ListBuilder<AiChatPostRequestMessagesInner>(),
        )
        ..addBuilderFactory(
          const FullType(
            BuiltList,
            <FullType>[FullType(AdminStatsGet200ResponseRecentMembersInner)],
          ),
          () => ListBuilder<AdminStatsGet200ResponseRecentMembersInner>(),
        )
        ..addPlugin(StandardJsonPlugin()))
      .build();

  static final Serializers _serializers = (Serializers().toBuilder()
        ..add(AdminProfileGet200Response.serializer)
        ..add(AdminProfileGet200ResponseUser.serializer)
        ..add(AdminStatsGet200Response.serializer)
        ..add(AdminStatsGet200ResponseRecentMembersInner.serializer)
        ..add(AiChatPost200Response.serializer)
        ..add(AiChatPostRequest.serializer)
        ..add(AiChatPostRequestMessagesInner.serializer)
        ..add(Appointment.serializer)
        ..add(AuthLoginPasswordPost200Response.serializer)
        ..add(AuthLoginPasswordPostRequest.serializer)
        ..add(AuthRequestOtpPost200Response.serializer)
        ..add(AuthRequestOtpPostRequest.serializer)
        ..add(AuthVerifyOtpPost200Response.serializer)
        ..add(AuthVerifyOtpPostRequest.serializer)
        ..add(Error.serializer)
        ..add(HealthGet200Response.serializer)
        ..add(MemberAiPrescoreGet200Response.serializer)
        ..add(MemberAppointmentsGet200Response.serializer)
        ..add(MemberAppointmentsPost200Response.serializer)
        ..add(MemberAppointmentsPostRequest.serializer)
        ..add(MemberProfileGet200Response.serializer)
        ..add(MemberProfileGet200ResponseProfile.serializer)
        ..add(MemberProfileGet200ResponseUser.serializer)
        ..add(MemberProfilePost200Response.serializer)
        ..add(MemberProfilePostRequest.serializer)
        ..add(MemberQuestionnaireSubmitPost200Response.serializer)
        ..add(MemberQuestionnaireSubmitPost200ResponseScoring.serializer)
        ..add(MemberQuestionnaireSubmitPost200ResponseScoringRuleScore.serializer)
        ..add(MemberSummaryGet200Response.serializer)
        ..add(MemberSymptomsGet200Response.serializer)
        ..add(MemberSymptomsPost200Response.serializer)
        ..add(MemberSymptomsPostRequest.serializer)
        ..add(MemberTestsGet200Response.serializer)
        ..add(MemberTestsGet200ResponseAttachmentsInner.serializer)
        ..add(MemberTestsGet200ResponseAttachmentsInnerUploader.serializer)
        ..add(MemberTestsPostRequest.serializer)
        ..add(Plan.serializer)
        ..add(PlansGet200Response.serializer)
        ..add(PlansPost200Response.serializer)
        ..add(PlansPostRequest.serializer)
        ..add(R2PresignPost200Response.serializer)
        ..add(R2PresignPostRequest.serializer)
        ..add(SymptomEntry.serializer)
        ..add(SymptomEntrySymptoms.serializer)
        ..add(User.serializer))
      .build();
}
