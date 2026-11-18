import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../network/api_repository.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

final GetIt getIt = GetIt.instance;

/// Registers feature repositories. `main.dart` passes the API versions and
/// `main_sample.dart` the sample versions, so release builds of `main.dart`
/// never include sample data (constitution §2 rule 6).
typedef RepositoryRegistrar = void Function(GetIt getIt);

void configureDependencies(RepositoryRegistrar registerRepositories) {
  if (getIt.isRegistered<DioClient>()) return;

  getIt.registerLazySingleton<Connectivity>(Connectivity.new);
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfo(getIt<Connectivity>()));
  getIt.registerLazySingleton<DioClient>(() => DioClient(tokenProvider: () async => null));
  getIt.registerLazySingleton<ApiRepository>(() => ApiRepository(getIt<DioClient>().instance));

  registerRepositories(getIt);
}
