import '../entities/user_page.dart';

abstract class UserRepository {
  Future<UserPage> getUsers({required int page, required int perPage});
}
