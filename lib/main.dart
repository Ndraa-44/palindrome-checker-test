import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:km_test/app/app.dart';
import 'package:km_test/injection_container.dart' as di;
import 'package:km_test/features/session/presentation/bloc/session_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<SessionBloc>()),
      ],
      child: const App(),
    ),
  );
}
