import 'package:equatable/equatable.dart';

class SessionState extends Equatable {
  final String name;
  final String selectedUserName;

  const SessionState({
    this.name = '',
    this.selectedUserName = '',
  });

  SessionState copyWith({
    String? name,
    String? selectedUserName,
  }) {
    return SessionState(
      name: name ?? this.name,
      selectedUserName: selectedUserName ?? this.selectedUserName,
    );
  }

  @override
  List<Object> get props => [name, selectedUserName];
}
