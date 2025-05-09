// navigation for go router page
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/ui/add_task_screen.dart';
import 'package:todo_app/ui/dashboard_screen.dart';
import 'package:todo_app/ui/login_page.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/auth/auth_bloc.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final isAuthenticated = authBloc.state.status == AuthStatus.authenticated;
      final isLoginRoute = state.uri.toString() == '/login';

      // If user is not authenticated and not on login route, redirect to login
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      // If user is authenticated and on login route, redirect to dashboard
      if (isAuthenticated && isLoginRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/dashboard'),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(path: '/add', builder: (context, state) => const AddTaskScreen()),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}

// Helper class to make Bloc's state stream usable with GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
