import 'package:equatable/equatable.dart';

class SessionState extends Equatable {
  final String name;
  final String selectedUserName;
  final String selectedUserEmail;

  const SessionState({
    this.name = '',
    this.selectedUserName = '',
    this.selectedUserEmail = '',
  });

  SessionState copyWith({
    String? name,
    String? selectedUserName,
    String? selectedUserEmail,
  }) {
    return SessionState(
      name: name ?? this.name,
      selectedUserName: selectedUserName ?? this.selectedUserName,
      selectedUserEmail: selectedUserEmail ?? this.selectedUserEmail,
    );
  }

  @override
  List<Object> get props => [name, selectedUserName, selectedUserEmail];
}
