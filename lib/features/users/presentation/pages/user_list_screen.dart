import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:km_test/core/theme/app_theme.dart';
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
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Third Screen',
          style: GoogleFonts.literata(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.tertiaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.1),
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.users.length + (state.hasReachedMax ? 0 : 1),
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: DashedDivider(),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: user.avatar,
                            width: 52,
                            height: 52,
                            memCacheWidth: 104, // 52 * 2 (supports high-density screens)
                            memCacheHeight: 104,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '${user.firstName} ${user.lastName}',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700, 
                              fontSize: 16,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          user.email,
                          style: GoogleFonts.jetBrainsMono(
                            color: AppTheme.hintTextColor, 
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        onTap: () {
                          context.read<SessionBloc>()
                              .add(SaveSelectedUser('${user.firstName} ${user.lastName}', user.email));
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4)),
              ),
            );
          }),
        );
      },
    );
  }
}
