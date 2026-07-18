import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum UserListStatus { initial, loading, success, failure }

class UserListState extends Equatable {
  final UserListStatus status;
  final List<User> users;
  final int page;
  final int totalPages;
  final String? errorMessage;
  final bool hasReachedMax;

  const UserListState({
    this.status = UserListStatus.initial,
    this.users = const [],
    this.page = 1,
    this.totalPages = 1,
    this.errorMessage,
    this.hasReachedMax = false,
  });

  UserListState copyWith({
    UserListStatus? status,
    List<User>? users,
    int? page,
    int? totalPages,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return UserListState(
      status: status ?? this.status,
      users: users ?? this.users,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, users, page, totalPages, errorMessage, hasReachedMax];
}
