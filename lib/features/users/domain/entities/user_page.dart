import 'package:equatable/equatable.dart';
import 'user.dart';

class UserPage extends Equatable {
  final List<User> users;
  final int page;
  final int totalPages;

  const UserPage({
    required this.users,
    required this.page,
    required this.totalPages,
  });

  @override
  List<Object> get props => [users, page, totalPages];
}
