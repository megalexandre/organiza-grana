import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:organizagrana/app/auth_session_controller.dart';
import 'package:organizagrana/features/auth/presentation/pages/login_page.dart';
import 'package:organizagrana/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:organizagrana/features/recebiveis/presentation/pages/recebiveis_page.dart';

class AppRouter {
  AppRouter(this._session);

  final AuthSessionController _session;
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static const String rootPath = '/';
  static const String loginPath = '/login';
  static const String dashboardPath = '/dashboard';
  static const String recebiveisPath = '/dashboard/recebiveis';

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: rootPath,
    refreshListenable: _session,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLogin = location == loginPath;
      final isRoot = location == rootPath;

      if (!_session.initialized) {
        return isRoot ? null : rootPath;
      }

      if (!_session.isAuthenticated) {
        return isLogin ? null : loginPath;
      }

      if (isRoot || isLogin) {
        return dashboardPath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: rootPath,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _LoadingPage(),
        ),
      ),
      GoRoute(
        path: loginPath,
        pageBuilder: (context, state) => NoTransitionPage(
          child: LoginPage(onLogin: _session.login),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final currentItemId =
              state.uri.path == recebiveisPath ? 'recebiveis' : 'dashboard';

          return DashboardPage(
            onLogout: _session.logout,
            userEmail: _session.userEmail,
            currentItemId: currentItemId,
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: dashboardPath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardHomeContent(),
            ),
            routes: [
              GoRoute(
                path: 'recebiveis',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: RecebiveisPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}