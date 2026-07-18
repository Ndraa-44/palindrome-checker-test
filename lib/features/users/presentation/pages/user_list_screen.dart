import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:km_test/features/session/presentation/bloc/session_bloc.dart';
import 'package:km_test/features/session/presentation/bloc/session_event.dart';
import 'package:km_test/features/users/presentation/bloc/user_list_bloc.dart';
import 'package:km_test/features/users/presentation/bloc/user_list_event.dart';
import 'package:km_test/features/users/presentation/bloc/user_list_state.dart';
import 'package:km_test/shared/widgets/loading_indicator.dart';
import 'package:km_test/shared/widgets/empty_state_widget.dart';
import 'package:km_test/shared/widgets/error_state_widget.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<UserListBloc>().add(const FetchUsers(isRefresh: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      context.read<UserListBloc>().add(LoadMoreUsers());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Third Screen',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF554AF0)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
        ),
      ),
      body: BlocBuilder<UserListBloc, UserListState>(
        builder: (context, state) {
          if (state.status == UserListStatus.loading && state.users.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.status == UserListStatus.failure && state.users.isEmpty) {
            return ErrorStateWidget(
              message: state.errorMessage ?? 'Unknown error',
              onRetry: () => context.read<UserListBloc>().add(const FetchUsers(isRefresh: true)),
            );
          }

          if (state.users.isEmpty) {
            return const EmptyStateWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserListBloc>().add(const FetchUsers(isRefresh: true));
            },
            child: ListView.separated(
              controller: _scrollController,
              itemCount: state.users.length + (state.hasReachedMax ? 0 : 1),
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                if (index >= state.users.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = state.users[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.avatar),
                    radius: 28,
                  ),
                  title: Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    user.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    context.read<SessionBloc>()
                        .add(SaveSelectedUser('${user.firstName} ${user.lastName}'));
                    Navigator.pop(context);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
