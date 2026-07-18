import 'package:flutter_bloc/flutter_bloc.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc() : super(const SessionState()) {
    on<SaveName>((event, emit) {
      emit(state.copyWith(name: event.name));
    });
    
    on<SaveSelectedUser>((event, emit) {
      emit(state.copyWith(selectedUserName: event.selectedUserName));
    });
  }
}
