import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_list_event.dart';
import 'user_list_state.dart';
import '../../domain/usecases/get_users.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final GetUsers getUsers;

  UserListBloc({required this.getUsers}) : super(const UserListState()) {
    on<FetchUsers>(_onFetchUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserListState> emit) async {
    if (event.isRefresh) {
      emit(const UserListState(status: UserListStatus.loading));
    } else if (state.status == UserListStatus.initial) {
      emit(state.copyWith(status: UserListStatus.loading));
    }

    try {
      final userPage = await getUsers(page: 1, perPage: 10);
      emit(state.copyWith(
        status: UserListStatus.success,
        users: userPage.users,
        page: 1,
        totalPages: userPage.totalPages,
        hasReachedMax: 1 >= userPage.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreUsers(LoadMoreUsers event, Emitter<UserListState> emit) async {
    if (state.hasReachedMax || state.status == UserListStatus.loading) return;

    try {
      final nextPage = state.page + 1;
      final userPage = await getUsers(page: nextPage, perPage: 10);
      emit(state.copyWith(
        status: UserListStatus.success,
        users: List.of(state.users)..addAll(userPage.users),
        page: nextPage,
        hasReachedMax: nextPage >= userPage.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
