import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../network/api_repository.dart';
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

  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSource(getIt<ApiRepository>()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<HomeRemoteDataSource>()),
  );
  getIt.registerFactory<HomeBloc>(() => HomeBloc(getIt<HomeRepository>()));
}
