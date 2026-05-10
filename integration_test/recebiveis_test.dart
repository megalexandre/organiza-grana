import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Recebíveis', () {
    Future<void> startAuthenticated(
      WidgetTester tester,
      RouteTable extraRoutes,
    ) async {
      final token = fakeJwt();
      final client = buildMockClient({
        'GET /api/users/me': http.Response(
          encode(getMeBody),
          200,
          headers: {'content-type': 'application/json'},
        ),
        ...extraRoutes,
      });
      await pumpAuthenticated(tester, client, token);
    }

    testWidgets('navega para Recebíveis e exibe a lista', (tester) async {
      await startAuthenticated(tester, {
        'GET /api/receivables': http.Response(
          encode(receivablesPageBody(count: 2)),
          200,
          headers: {'content-type': 'application/json'},
        ),
      });

      // Toca no item de menu Recebíveis
      await tester.tap(find.text('Recebíveis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Resumo deve mostrar o total de recebíveis
      expect(find.textContaining('2 Recebiv'), findsOneWidget);
    });

    testWidgets('exibe estado vazio quando lista retorna sem itens', (tester) async {
      await startAuthenticated(tester, {
        'GET /api/receivables': http.Response(
          encode(receivablesPageBody(count: 0)),
          200,
          headers: {'content-type': 'application/json'},
        ),
      });

      await tester.tap(find.text('Recebíveis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Nenhum recebível encontrado.'), findsOneWidget);
    });

    testWidgets('exibe erro e botão de retry quando API retorna 500', (tester) async {
      await startAuthenticated(tester, {
        'GET /api/receivables': http.Response(
          '{"error":"internal server error"}',
          500,
          headers: {'content-type': 'application/json'},
        ),
      });

      await tester.tap(find.text('Recebíveis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('FAB de novo recebível está presente', (tester) async {
      await startAuthenticated(tester, {
        'GET /api/receivables': http.Response(
          encode(receivablesPageBody()),
          200,
          headers: {'content-type': 'application/json'},
        ),
      });

      await tester.tap(find.text('Recebíveis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
