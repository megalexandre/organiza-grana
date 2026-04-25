

import 'package:flutter/material.dart';
import 'package:organizagrana/app/app_theme.dart';
import 'package:organizagrana/features/auth/presentation/pages/auth_gate.dart';
import 'package:organizagrana/l10n/app_localizations.dart';


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const AuthGate(),
    );
  }
}
