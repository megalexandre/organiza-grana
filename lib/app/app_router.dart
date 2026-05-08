import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:organizagrana/app/auth_session_controller.dart';
import 'package:organizagrana/features/auth/presentation/pages/login_page.dart';
import 'package:organizagrana/features/bordero/data/bordero_service.dart';
import 'package:organizagrana/features/bordero/presentation/pages/bordero_page.dart';
import 'package:organizagrana/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:organizagrana/features/holidays/data/holidays_service.dart';
import 'package:organizagrana/features/holidays/presentation/pages/holidays_page.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/presentation/pages/recebiveis_page.dart';

class AppRouter {
  AppRouter(
    this._session, {
    required ReceivablesService receivablesService,
    required BorderoService borderoService,
    required HolidaysService holidaysService,
  })  : _receivablesService = receivablesService,
        _borderoService = borderoService,
        _holidaysService = holidaysService;

  final AuthSessionController _session;
  final ReceivablesService _receivablesService;
  final BorderoService _borderoService;
  final HolidaysService _holidaysService;
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static const String rootPath = '/';
  static const String loginPath = '/login';
  static const String dashboardPath = '/dashboard';
  static const String recebiveisPath = '/dashboard/recebiveis';
  static const String borderoPath = '/dashboard/bordero';
  static const String holidaysPath = '/dashboard/holidays';

  static String pathForItem(String itemId) => switch (itemId) {
        'recebiveis' => recebiveisPath,
        'bordero' => borderoPath,
        'holidays' => holidaysPath,
        _ => dashboardPath,
      };

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
          final currentItemId = switch (state.uri.path) {
            recebiveisPath => 'recebiveis',
            borderoPath => 'bordero',
            holidaysPath => 'holidays',
            _ => 'dashboard',
          };

          return DashboardPage(
            onLogout: _session.logout,
            currentItemId: currentItemId,
            userEmail: _session.displayEmail,
            userAvatarUrl: _session.userAvatarUrl,
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
                pageBuilder: (context, state) => NoTransitionPage(
                  child: RecebiveisPage(service: _receivablesService),
                ),
              ),
              GoRoute(
                path: 'bordero',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BorderoPage(service: _borderoService),
                ),
              ),
              GoRoute(
                path: 'holidays',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: HolidaysPage(service: _holidaysService),
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