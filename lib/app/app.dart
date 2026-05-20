import 'package:flutter/material.dart';
import 'package:organizagrana/app/app_router.dart';
import 'package:organizagrana/app/app_theme.dart';
import 'package:organizagrana/app/auth_session_controller.dart';
import 'package:organizagrana/features/auth/data/auth_access_token_provider.dart';
import 'package:organizagrana/features/auth/data/auth_service.dart';
import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/bordero/data/bordero_api_client.dart';
import 'package:organizagrana/features/bordero/data/bordero_service.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_api_client.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_service.dart';
import 'package:organizagrana/features/holidays/data/holidays_api_client.dart';
import 'package:organizagrana/features/holidays/data/holidays_service.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_api_client.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/l10n/app_localizations.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';
import 'package:organizagrana/shared/theme/theme_controller.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AuthSessionController _session;
  late final AppRouter _appRouter;
  final _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.load();

    final authStorage = AuthStorage();
    final authService = AuthService(authStorage);
    _session = AuthSessionController(authService: authService);

    final tokenProvider = AuthStorageAccessTokenProvider(authStorage);
    final httpClient = HttpApiClient(
      bearerTokenProvider: tokenProvider.readAccessToken,
      tokenRefresher: authService.refreshAccessToken,
    );

    final receivablesService = ReceivablesService(
      HttpReceivablesApiClient(tokenProvider, httpClient: httpClient),
    );
    final borderoService = BorderoService(
      HttpBorderoApiClient(tokenProvider, httpClient: httpClient),
    );
    final holidaysService = HolidaysService(
      HttpHolidaysApiClient(tokenProvider, httpClient: httpClient),
    );
    final dashboardService = DashboardService(
      HttpDashboardApiClient(tokenProvider, httpClient: httpClient),
    );
    _appRouter = AppRouter(
      _session,
      receivablesService: receivablesService,
      borderoService: borderoService,
      holidaysService: holidaysService,
      dashboardService: dashboardService,
    );
    _session.initialize();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeProvider(
      controller: _themeController,
      child: ValueListenableBuilder(
        valueListenable: _themeController,
        builder: (_, themeMode, _) => MaterialApp.router(
          routerConfig: _appRouter.router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
        ),
      ),
    );
  }
}
