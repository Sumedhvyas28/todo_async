import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app_router.dart';
import 'package:todo_app/bloc/auth/auth_bloc.dart';
import 'package:todo_app/data/auth_repository.dart';
import 'package:todo_app/data/task_repository.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/ui/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthRepository authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authRepository),
          RepositoryProvider(
            create: (context) => TaskRepository(authRepository: authRepository),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>()))
          ],
          child: Builder(
            builder: (context) {
              final appRouter = AppRouter(authBloc: context.read<AuthBloc>());
              return MaterialApp.router(
                routerConfig: appRouter.router,
                debugShowCheckedModeBanner: false,
                title: 'Flutter Demo',
                theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                ),
              );
            },
          ),
        ));
  }
}
