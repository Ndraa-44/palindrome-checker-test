import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:km_test/features/session/presentation/pages/home_screen.dart';
import 'package:km_test/features/session/presentation/pages/welcome_screen.dart';
import 'package:km_test/features/users/presentation/pages/user_list_screen.dart';
import 'package:km_test/features/users/presentation/bloc/user_list_bloc.dart';
import 'package:km_test/injection_container.dart' as di;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KM Test',
      theme: ThemeData(
        fontFamily: 'Poppins', // Or default if poppins isn't imported
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2B637B)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/users': (context) => BlocProvider(
              create: (_) => di.sl<UserListBloc>(),
              child: const UserListScreen(),
            ),
      },
    );
  }
}
