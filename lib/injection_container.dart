import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'features/session/presentation/bloc/session_bloc.dart';
import 'features/users/data/datasources/user_remote_data_source.dart';
import 'features/users/data/repositories/user_repository_impl.dart';
import 'features/users/domain/repositories/user_repository.dart';
import 'features/users/domain/usecases/get_users.dart';
import 'features/users/presentation/bloc/user_list_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => SessionBloc());
  sl.registerFactory(() => UserListBloc(getUsers: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetUsers(sl()));

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: sl()),
  );

  // External
  sl.registerLazySingleton(() => http.Client());
}
