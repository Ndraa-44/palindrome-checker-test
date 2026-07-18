import '../entities/user_page.dart';
import '../repositories/user_repository.dart';

class GetUsers {
  final UserRepository repository;

  GetUsers(this.repository);

  Future<UserPage> call({required int page, required int perPage}) {
    return repository.getUsers(page: page, perPage: perPage);
  }
}
