import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

class SaveName extends SessionEvent {
  final String name;

  const SaveName(this.name);

  @override
  List<Object> get props => [name];
}

class SaveSelectedUser extends SessionEvent {
  final String selectedUserName;

  const SaveSelectedUser(this.selectedUserName);

  @override
  List<Object> get props => [selectedUserName];
}
