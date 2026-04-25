

import 'package:flutter/material.dart';
import 'package:organizagrana/app/app_router.dart';
import 'package:organizagrana/app/app_theme.dart';
import 'package:organizagrana/app/auth_session_controller.dart';
import 'package:organizagrana/l10n/app_localizations.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AuthSessionController _session;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _session = AuthSessionController();
    _appRouter = AppRouter(_session);
    _session.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
    );
  }
}
