// SAMPLE wiring, imported only from lib/main_sample.dart.

import 'package:get_it/get_it.dart';

import '../app/device_services.dart';
import '../app/unavailable_member_areas.dart';
import '../features/account/domain/account.dart';
import '../features/assessment/domain/assessment_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/billing/domain/billing.dart';
import '../features/care/domain/care.dart';
import '../features/chat/domain/chat.dart';
import '../features/community/domain/community.dart';
import '../features/consults/domain/consults.dart';
import '../features/cycle/domain/cycle.dart';
import '../features/devices/domain/devices.dart';
import '../features/dietitian/dietitian_repository.dart';
import '../features/doctor/domain/doctor.dart';
import '../features/doctor/domain/doctor_work.dart';
import '../features/home/domain/home.dart';
import '../features/instructor/instructor_repository.dart';
import '../features/labs/domain/labs.dart';
import '../features/me/domain/me.dart';
import '../features/meals/data/unavailable_meals_repository.dart';
import '../features/meals/domain/meals.dart';
import '../features/messaging/messaging.dart';
import '../features/plans/domain/plan.dart';
import '../features/practice/domain/practice.dart';
import '../features/provider_auth/application_repository.dart';
import '../features/provider_auth/domain/provider_auth.dart';
import '../features/provider_work/domain/provider_work.dart';
import '../features/symptoms/domain/symptoms.dart';
import '../features/wellness_advice/domain/wellness_advice.dart';
import 'sample_backend.dart';
import 'sample_chat_repository.dart';
import 'sample_cycle_repository.dart';
import 'sample_doctor.dart';
import 'sample_home.dart';
import 'sample_provider_auth.dart';
import 'sample_second_check.dart';
import 'sample_store.dart';
import 'sample_symptoms_repository.dart';

void registerSampleRepositories(GetIt getIt) {
  final SampleBackend backend = SampleBackend();
  final SampleStore store = SampleStore();
  final SampleAuthRepository auth = SampleAuthRepository();
  getIt
    ..registerSingleton<SampleBackend>(backend)
    ..registerSingleton<SampleStore>(store)
    ..registerSingleton<AuthRepository>(auth)
    ..registerLazySingleton<SecondCheckRepository>(SampleSecondCheckRepository.new)
    ..registerLazySingleton<AssessmentRepository>(() => SampleAssessmentRepository(backend))
    ..registerLazySingleton<PlansRepository>(() => SamplePlansRepository(backend))
    ..registerLazySingleton<HomeRepository>(
      () => SampleHomeRepository(backend, store: store, name: () => auth.accountDetails?['displayName']),
    )
    ..registerLazySingleton<CycleRepository>(() => SampleCycleRepository(store, backend))
    ..registerLazySingleton<SymptomsRepository>(() => SampleSymptomsRepository(store, backend))
    ..registerLazySingleton<ChatRepository>(() => SampleChatRepository(store, backend))
    ..registerLazySingleton<ProviderAuthRepository>(SampleProviderAuthRepository.new)
    ..registerLazySingleton<DoctorRepository>(SampleDoctorRepository.new)
    ..registerLazySingleton<MealsRepository>(() => const UnavailableMealsRepository())
    ..registerLazySingleton<PracticeRepository>(UnavailablePracticeRepository.new)
    ..registerLazySingleton<MeRepository>(UnavailableMeRepository.new)
    ..registerLazySingleton<DevicesRepository>(UnavailableDevicesRepository.new)
    ..registerLazySingleton<CareRepository>(UnavailableCareRepository.new)
    ..registerLazySingleton<LabsRepository>(UnavailableLabsRepository.new)
    ..registerLazySingleton<CommunityRepository>(UnavailableCommunityRepository.new)
    ..registerLazySingleton<MessagingRepository>(UnavailableMessagingRepository.new)
    ..registerLazySingleton<ProviderWorkRepository>(UnavailableProviderWorkRepository.new)
    ..registerLazySingleton<DoctorWorkRepository>(UnavailableDoctorWorkRepository.new)
    ..registerLazySingleton<DietitianRepository>(UnavailableDietitianRepository.new)
    ..registerLazySingleton<InstructorRepository>(UnavailableInstructorRepository.new)
    ..registerLazySingleton<ProviderApplicationRepository>(UnavailableProviderApplicationRepository.new)
    // Consults, wellness advice, billing and sign-in settings exist only on the real API (constitution §2 rule 6).
    ..registerLazySingleton<ConsultsRepository>(UnavailableConsultsRepository.new)
    ..registerLazySingleton<WellnessAdviceRepository>(UnavailableWellnessAdviceRepository.new)
    ..registerLazySingleton<BillingRepository>(UnavailableBillingRepository.new)
    ..registerLazySingleton<AccountRepository>(UnavailableAccountRepository.new);
  // Video and the payment checkout: no sample reaches a room (no tokens) or takes a payment.
  registerDeviceServices(getIt, payments: false);
}
