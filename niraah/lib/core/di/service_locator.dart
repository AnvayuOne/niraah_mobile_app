import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/member/appointments/data/repositories/appointments_repository.dart';
import '../../features/member/appointments/presentation/bloc/appointments_cubit.dart';
import '../../features/member/chat_ai/data/repositories/chat_ai_repository.dart';
import '../../features/member/chat_ai/presentation/bloc/chat_ai_cubit.dart';
import '../../features/member/home/data/repositories/member_home_repository.dart';
import '../../features/member/home/presentation/bloc/member_home_cubit.dart';
import '../../features/member/medical_records/data/repositories/medical_records_repository.dart';
import '../../features/member/medical_records/presentation/bloc/medical_records_cubit.dart';
import '../../features/member/plans/data/repositories/plans_repository.dart';
import '../../features/member/plans/presentation/bloc/plans_cubit.dart';
import '../../features/member/prescore/data/repositories/prescore_repository.dart';
import '../../features/member/prescore/presentation/bloc/prescore_cubit.dart';
import '../../features/member/profile/data/repositories/profile_repository.dart';
import '../../features/member/profile/presentation/bloc/profile_cubit.dart';
import '../../features/member/progress_dashboard/data/repositories/progress_repository.dart';
import '../../features/member/progress_dashboard/presentation/bloc/progress_cubit.dart';
import '../../features/member/questionnaire/data/repositories/questionnaire_repository.dart';
import '../../features/member/questionnaire/presentation/bloc/questionnaire_cubit.dart';
import '../../features/member/symptoms/data/repositories/symptoms_repository.dart';
import '../../features/member/symptoms/presentation/bloc/symptoms_cubit.dart';
import '../network/api_repository.dart';
import '../network/api_service.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<HomeBloc>()) {
    return;
  }

  getIt.registerLazySingleton<Connectivity>(Connectivity.new);
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfo(getIt<Connectivity>()));

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      tokenProvider: () async => null,
    ),
  );

  getIt.registerLazySingleton<ApiRepository>(
    () => ApiRepository(getIt<DioClient>().instance),
  );
  getIt.registerLazySingleton<ApiService>(() => ApiService.instance);

  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSource(getIt<ApiRepository>()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<HomeRemoteDataSource>()),
  );
  getIt.registerFactory<HomeBloc>(() => HomeBloc(getIt<HomeRepository>()));

  getIt.registerLazySingleton<MemberHomeRepository>(
    () => MemberHomeRepository(getIt<ApiService>()),
  );
  getIt.registerFactory<MemberHomeCubit>(() => MemberHomeCubit(getIt<MemberHomeRepository>()));

  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository(getIt<ApiService>()));
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt<ProfileRepository>()));

  getIt.registerLazySingleton<QuestionnaireRepository>(
    () => QuestionnaireRepository(getIt<ApiService>()),
  );
  getIt.registerFactory<QuestionnaireCubit>(
    () => QuestionnaireCubit(getIt<QuestionnaireRepository>()),
  );

  getIt.registerLazySingleton<PrescoreRepository>(() => PrescoreRepository(getIt<ApiService>()));
  getIt.registerFactory<PrescoreCubit>(() => PrescoreCubit(getIt<PrescoreRepository>()));

  getIt.registerLazySingleton<PlansRepository>(() => PlansRepository(getIt<ApiService>()));
  getIt.registerFactory<PlansCubit>(() => PlansCubit(getIt<PlansRepository>()));

  getIt.registerLazySingleton<SymptomsRepository>(() => SymptomsRepository(getIt<ApiService>()));
  getIt.registerFactory<SymptomsCubit>(() => SymptomsCubit(getIt<SymptomsRepository>()));

  getIt.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepository(getIt<ApiService>()),
  );
  getIt.registerFactory<AppointmentsCubit>(
    () => AppointmentsCubit(getIt<AppointmentsRepository>()),
  );

  getIt.registerLazySingleton<MedicalRecordsRepository>(
    () => MedicalRecordsRepository(getIt<ApiService>()),
  );
  getIt.registerFactory<MedicalRecordsCubit>(
    () => MedicalRecordsCubit(getIt<MedicalRecordsRepository>()),
  );

  getIt.registerLazySingleton<ChatAiRepository>(() => ChatAiRepository(getIt<ApiService>()));
  getIt.registerFactory<ChatAiCubit>(() => ChatAiCubit(getIt<ChatAiRepository>()));

  getIt.registerLazySingleton<ProgressRepository>(() => ProgressRepository(getIt<ApiService>()));
  getIt.registerFactory<ProgressCubit>(() => ProgressCubit(getIt<ProgressRepository>()));
}
