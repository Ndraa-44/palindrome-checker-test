import '../../domain/entities/user.dart';
import '../../domain/entities/user_page.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    avatar: json['avatar'],
  );
}

class UserPageModel extends UserPage {
  const UserPageModel({
    required super.users,
    required super.page,
    required super.totalPages,
  });

  factory UserPageModel.fromJson(Map<String, dynamic> json) => UserPageModel(
    users: (json['data'] as List).map((e) => UserModel.fromJson(e)).toList(),
    page: json['page'],
    totalPages: json['total_pages'],
  );
}
