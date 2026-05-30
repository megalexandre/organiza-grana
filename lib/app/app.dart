import 'package:flutter/material.dart';
import 'package:organizagrana/app/app_dependencies.dart';
import 'package:organizagrana/app/app_router.dart';
import 'package:organizagrana/app/app_theme.dart';
import 'package:organizagrana/app/auth_session_controller.dart';
import 'package:organizagrana/l10n/app_localizations.dart';
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

    final deps = AppDependencies.create();
    _session = deps.session;
    _appRouter = deps.router;
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
