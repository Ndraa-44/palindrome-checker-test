import '../../domain/entities/user_page.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserPage> getUsers({required int page, required int perPage}) async {
    return await remoteDataSource.getUsers(page: page, perPage: perPage);
  }
}
