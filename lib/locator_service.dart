

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_task/core/platform/network_info.dart';
import 'package:test_task/feature/data/datasources/photo_local_data_source.dart';
import 'package:test_task/feature/data/datasources/photo_local_data_source_impl.dart';
import 'package:test_task/feature/data/datasources/photo_remote_data_source.dart';
import 'package:test_task/feature/data/datasources/photo_remote_data_source_impl.dart';
import 'package:test_task/feature/data/repositories/photo_repository_impl.dart';
import 'package:test_task/feature/domain/repositories/photo_repository.dart';
import 'package:test_task/feature/domain/usecases/get_all_photos.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_cubit.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // BLoC / Cubit
  sl.registerFactory(
        () => PhotoListCubit(getAllPhotos: sl<GetAllPhotos>()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetAllPhotos(sl()));

  // Repository
  sl.registerLazySingleton<PhotoRepository>(
        () => PhotoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<PhotoRemoteDataSource>(
        () => PhotoRemoteDataSourceImpl(
      client: sl(),
    ),
  );

  sl.registerLazySingleton<PhotoLocalDataSource>(
        () => PhotoLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImp(sl()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}