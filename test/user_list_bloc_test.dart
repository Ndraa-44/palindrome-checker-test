import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:km_test/features/users/domain/entities/user.dart';
import 'package:km_test/features/users/domain/entities/user_page.dart';
import 'package:km_test/features/users/domain/usecases/get_users.dart';
import 'package:km_test/features/users/presentation/bloc/user_list_bloc.dart';
import 'package:km_test/features/users/presentation/bloc/user_list_event.dart';
import 'package:km_test/features/users/presentation/bloc/user_list_state.dart';

class MockGetUsers extends Mock implements GetUsers {}

void main() {
  late UserListBloc bloc;
  late MockGetUsers mockGetUsers;

  setUp(() {
    mockGetUsers = MockGetUsers();
    bloc = UserListBloc(getUsers: mockGetUsers);
  });

  tearDown(() {
    bloc.close();
  });

  group('UserListBloc', () {
    const mockUser = User(
      id: 1,
      email: 'test@test.com',
      firstName: 'John',
      lastName: 'Doe',
      avatar: 'https://test.com/avatar.jpg',
    );

    const mockResponse = UserPage(
      users: [mockUser],
      page: 1,
      totalPages: 2,
    );

    blocTest<UserListBloc, UserListState>(
      'emits [loading, success] when FetchUsers is added',
      build: () {
        when(() => mockGetUsers(page: 1, perPage: 10))
            .thenAnswer((_) async => mockResponse);
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [
        const UserListState(status: UserListStatus.loading),
        const UserListState(
          status: UserListStatus.success,
          users: [mockUser],
          page: 1,
          totalPages: 2,
          hasReachedMax: false,
        ),
      ],
    );
  });
}
