import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:organizagrana/app/app_dependencies.dart';
import 'package:organizagrana/app/app_router.dart';
import 'package:organizagrana/app/app_theme.dart';
import 'package:organizagrana/app/auth_session_controller.dart';
import 'package:organizagrana/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tabela de rotas mock: chave = "METHOD /path", valor = Response
typedef RouteTable = Map<String, http.Response>;

MockClient buildMockClient(RouteTable routes) {
  return MockClient((request) async {
    final key = '${request.method} ${request.url.path}';
    return routes[key] ?? http.Response('{"error":"not found"}', 404);
  });
}

// Resposta de erro de rede: cliente que sempre lança exceção
MockClient buildErrorClient() {
  return MockClient((_) async => throw Exception('Sem conexão'));
}

class TestApp extends StatefulWidget {
  const TestApp({super.key, required this.httpClient});
  final http.Client httpClient;

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  late final AuthSessionController _session;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();

    // Mesmo composition root do app real, com o http.Client mockado injetado.
    final deps = AppDependencies.create(httpClient: widget.httpClient);
    _session = deps.session;
    _appRouter = deps.router;

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

// Inicia o app sem autenticação (sem tokens no storage)
Future<void> pumpUnauthenticated(
  WidgetTester tester,
  http.Client httpClient,
) async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  await tester.pumpWidget(TestApp(httpClient: httpClient));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

// Inicia o app já autenticado (token fake no storage)
Future<void> pumpAuthenticated(
  WidgetTester tester,
  http.Client httpClient,
  String accessToken, {
  String refreshToken = 'fake-refresh',
}) async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({
    'access_token': accessToken,
    'refresh_token': refreshToken,
  });
  await tester.pumpWidget(TestApp(httpClient: httpClient));
  // Aguarda inicialização da sessão + redirecionamento do router + carregamento do menu
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}
