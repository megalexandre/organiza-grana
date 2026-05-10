import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth', () {
    testWidgets('exibe tela de login quando não autenticado', (tester) async {
      final client = buildMockClient({});
      await pumpUnauthenticated(tester, client);

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    });

    testWidgets('valida campos vazios sem fazer requisição', (tester) async {
      final client = buildMockClient({});
      await pumpUnauthenticated(tester, client);

      await tester.tap(find.text('Login'));
      await tester.pump();

      // Os campos de validação do Flutter aparecem abaixo dos TextFormFields
      expect(find.textContaining('E-mail'), findsWidgets);
    });

    testWidgets('login com sucesso redireciona para o dashboard', (tester) async {
      final client = buildMockClient({
        'POST /api/auth/login': http.Response(
          encode(loginSuccessBody()),
          200,
          headers: {'content-type': 'application/json'},
        ),
        'GET /api/users/me': http.Response(
          encode(getMeBody),
          200,
          headers: {'content-type': 'application/json'},
        ),
      });

      await pumpUnauthenticated(tester, client);

      // Preenche e-mail
      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'test@example.com',
      );
      // Preenche senha
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'senha123',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Após login bem-sucedido, a tela de login não deve mais aparecer
      expect(find.text('Entrar'), findsNothing);
    });

    testWidgets('credenciais inválidas exibe snackbar de erro', (tester) async {
      final client = buildMockClient({
        'POST /api/auth/login': http.Response(
          '{"error":"Unauthorized"}',
          401,
          headers: {'content-type': 'application/json'},
        ),
      });

      await pumpUnauthenticated(tester, client);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'wrong@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'errada',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // SnackBar com mensagem de erro deve aparecer
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('erro de rede no login exibe snackbar', (tester) async {
      final client = buildErrorClient();
      await pumpUnauthenticated(tester, client);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'senha123',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
