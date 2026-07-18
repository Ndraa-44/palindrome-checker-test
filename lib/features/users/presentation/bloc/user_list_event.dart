import 'package:equatable/equatable.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object> get props => [];
}

class FetchUsers extends UserListEvent {
  final bool isRefresh;
  const FetchUsers({this.isRefresh = false});
  
  @override
  List<Object> get props => [isRefresh];
}

class LoadMoreUsers extends UserListEvent {}
