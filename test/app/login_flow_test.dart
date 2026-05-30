import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:organizagrana/app/app_dependencies.dart';
import 'package:organizagrana/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Teste de fluxo REAL: monta o wiring de produção (AppDependencies → router,
// sessão, LoginPage e DashboardPage reais) e dirige login → dashboard.
// Diferente do login_page_test.dart (que usa um onLogin stub), aqui exercitamos
// o caminho inteiro — é isto que pega regressões como "Duplicate GlobalKey" ou
// validação que impede o login.

String _fakeJwt([String email = 'alex@mail.com']) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final exp = now + 3600;
  String seg(String s) => base64Url.encode(utf8.encode(s)).replaceAll('=', '');
  final header = seg('{"alg":"HS256","typ":"JWT"}');
  final payload = seg('{"sub":"u1","email":"$email","iat":$now,"exp":$exp}');
  return '$header.$payload.sig';
}

http.Response _json(Object body) => http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json'},
    );

MockClient _buildClient({void Function(Map<String, dynamic> body)? onLogin}) {
  return MockClient((request) async {
    final key = '${request.method} ${request.url.path}';
    switch (key) {
      case 'POST /api/auth/login':
        onLogin?.call(jsonDecode(request.body) as Map<String, dynamic>);
        return _json({'access_token': _fakeJwt(), 'refresh_token': 'r1'});
      case 'GET /api/users/me':
        return _json({'id': 'u1', 'email': 'alex@mail.com', 'roles': ['user']});
      case 'GET /api/dashboard/receivables_by_status':
        return _json({'data': [{'status': 'awaiting', 'count': 1}]});
      case 'GET /api/dashboard/summary':
        return _json({
          'total_amount_cents': 1879998,
          'total_proceeds_cents': 1722079,
          'receivables_count': 6,
          'average_awaiting_days': 63.0,
        });
      case 'GET /api/receivables':
        return _json({
          'receivables': const [],
          'summary': {'count': 0, 'total_amount_cents': 0},
          'pagination': {'current_page': 1, 'per_page': 20, 'total_pages': 1, 'total_count': 0},
        });
      default:
        return http.Response('{"error":"not found"}', 404);
    }
  });
}

Future<void> _pumpApp(WidgetTester tester, http.Client client) async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});

  final deps = AppDependencies.create(httpClient: client);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: deps.router.router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  deps.session.initialize();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('usuário consegue logar digitando só o login e chega no dashboard',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Coletamos os erros do framework para inspecioná-los. Overflow de layout é
    // ruído da fonte de teste (Ahem) e é tolerado; erros estruturais como
    // "Duplicate GlobalKey" NÃO são — é o que esta regressão protege.
    final frameworkErrors = <String>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) => frameworkErrors.add(details.exceptionAsString());
    addTearDown(() => FlutterError.onError = previousOnError);

    Map<String, dynamic>? loginBody;
    await _pumpApp(tester, _buildClient(onLogin: (b) => loginBody = b));

    // Está na tela de login.
    expect(find.text('Entrar'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'alexandre');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'senha123');
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 1) O e-mail foi normalizado de fato no request real.
    expect(loginBody?['email'], 'alexandre@mail.com');
    // 2) Saiu da tela de login (navegou para o dashboard).
    expect(find.text('Entrar'), findsNothing);
    // 3) Nenhum erro estrutural (ex.: Duplicate GlobalKey) durante o fluxo.
    final structuralErrors = frameworkErrors
        .where((e) => !e.contains('overflowed'))
        .toList();
    expect(structuralErrors, isEmpty,
        reason: 'Erros estruturais durante login→dashboard: $structuralErrors');
  });
}
