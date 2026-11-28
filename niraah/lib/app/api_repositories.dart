import 'package:get_it/get_it.dart';

import '../core/auth/session_store.dart';
import '../core/network/dio_client.dart';
import '../core/network/niraah_api.dart';
import '../features/account/data/api_account_repository.dart';
import '../features/account/domain/account.dart';
import '../features/assessment/data/api_assessment_repository.dart';
import '../features/assessment/domain/assessment_repository.dart';
import '../features/auth/data/api_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/billing/data/api_billing_repository.dart';
import '../features/billing/domain/billing.dart';
import '../features/care/data/api_care_repository.dart';
import '../features/care/domain/care.dart';
import '../features/chat/data/api_chat_repository.dart';
import '../features/chat/domain/chat.dart';
import '../features/community/data/api_community_repository.dart';
import '../features/community/domain/community.dart';
import '../features/consults/data/api_consults_repository.dart';
import '../features/consults/domain/consults.dart';
import '../features/cycle/data/api_cycle_repository.dart';
import '../features/cycle/domain/cycle.dart';
import '../features/devices/data/api_devices_repository.dart';
import '../features/devices/domain/devices.dart';
import '../features/dietitian/dietitian_repository.dart';
import '../features/doctor/data/api_doctor_repository.dart';
import '../features/doctor/data/api_doctor_work_repository.dart';
import '../features/doctor/domain/doctor.dart';
import '../features/doctor/domain/doctor_work.dart';
import '../features/home/data/api_home_repository.dart';
import '../features/home/domain/home.dart';
import '../features/instructor/instructor_repository.dart';
import '../features/labs/data/api_labs_repository.dart';
import '../features/labs/domain/labs.dart';
import '../features/me/data/api_me_repository.dart';
import '../features/me/domain/me.dart';
import '../features/meals/data/api_meals_repository.dart';
import '../features/meals/domain/meals.dart';
import '../features/messaging/messaging.dart';
import '../features/plans/data/api_plans_repository.dart';
import '../features/plans/domain/plan.dart';
import '../features/practice/data/api_practice_repository.dart';
import '../features/practice/domain/practice.dart';
import '../features/provider_auth/application_repository.dart';
import '../features/provider_auth/data/api_provider_auth_repository.dart';
import '../features/provider_auth/domain/provider_auth.dart';
import '../features/provider_work/data/api_provider_work_repository.dart';
import '../features/provider_work/domain/provider_work.dart';
import '../features/symptoms/data/api_symptoms_repository.dart';
import '../features/symptoms/domain/symptoms.dart';
import '../features/wellness_advice/data/api_wellness_advice_repository.dart';
import '../features/wellness_advice/domain/wellness_advice.dart';
import 'device_services.dart';

/// Production repositories. Sign-in (spec 003), the assessment (spec 007), plans (spec 004), AI Care chat (spec 009) and Home, Cycle and Symptoms
/// (spec 010 §2-§4) run on `/api/v1`; the doctor workspace reports "not connected" instead of faking data until its endpoints exist.
void registerApiRepositories(GetIt getIt) {
  getIt
    ..registerLazySingleton<SessionStore>(SecureSessionStore.new)
    ..registerLazySingleton<NiraahApi>(() => NiraahApi(dio: getIt<DioClient>().instance, store: getIt<SessionStore>()))
    ..registerLazySingleton<ApiAuthRepository>(() => ApiAuthRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<AuthRepository>(() => getIt<ApiAuthRepository>())
    ..registerLazySingleton<SecondCheckRepository>(() => getIt<ApiAuthRepository>())
    ..registerLazySingleton<ProviderAuthRepository>(() => ApiProviderAuthRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<AssessmentRepository>(() => ApiAssessmentRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<PlansRepository>(() => ApiPlansRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<HomeRepository>(() => ApiHomeRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<CycleRepository>(() => ApiCycleRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<SymptomsRepository>(() => ApiSymptomsRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<ChatRepository>(() => ApiChatRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<MealsRepository>(() => ApiMealsRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<DoctorRepository>(() => ApiDoctorRepository(getIt<NiraahApi>()))
    // The rest of the member workspace (spec 010 §7, §9, §10-§13).
    ..registerLazySingleton<PracticeRepository>(() => ApiPracticeRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<MeRepository>(() => ApiMeRepository(getIt<NiraahApi>()))
    // Connected devices (spec 016).
    ..registerLazySingleton<DevicesRepository>(() => ApiDevicesRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<CareRepository>(() => ApiCareRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<LabsRepository>(() => ApiLabsRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<CommunityRepository>(() => ApiCommunityRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<MessagingRepository>(() => ApiMessagingRepository(getIt<NiraahApi>()))
    // Consults and wellness advice (specs 014, 011), manage plan and invoices (spec 008), sign-in settings (spec 003).
    ..registerLazySingleton<ConsultsRepository>(() => ApiConsultsRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<WellnessAdviceRepository>(() => ApiWellnessAdviceRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<BillingRepository>(() => ApiBillingRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<AccountRepository>(() => ApiAccountRepository(getIt<NiraahApi>()))
    // Provider workspaces (specs 008, 011, 014).
    ..registerLazySingleton<ProviderWorkRepository>(() => ApiProviderWorkRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<DoctorWorkRepository>(() => ApiDoctorWorkRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<DietitianRepository>(() => ApiDietitianRepository(getIt<NiraahApi>()))
    ..registerLazySingleton<InstructorRepository>(() => ApiInstructorRepository(getIt<NiraahApi>()))
    // Her own application (spec 006 §2).
    ..registerLazySingleton<ProviderApplicationRepository>(() => ApiProviderApplicationRepository(getIt<NiraahApi>()));
  // Video rooms and the payment checkout (specs 014, 008).
  registerDeviceServices(getIt);
}
