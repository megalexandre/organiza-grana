import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Holidays', () {
    final now = DateTime.now();

    Future<void> startAuthenticated(
      WidgetTester tester, {
      int? year,
      int? month,
      int statusCode = 200,
    }) async {
      final y = year ?? now.year;
      final m = month ?? now.month;
      final token = fakeJwt();
      final client = buildMockClient({
        'GET /api/users/me': http.Response(
          encode(getMeBody),
          200,
          headers: {'content-type': 'application/json'},
        ),
        'GET /api/holidays': http.Response(
          statusCode == 200
              ? encode(holidaysCalendarBody(y, m))
              : '{"error":"server error"}',
          statusCode,
          headers: {'content-type': 'application/json'},
        ),
      });
      await pumpAuthenticated(tester, client, token);
    }

    testWidgets('navega para Holidays e exibe o calendário do mês atual', (tester) async {
      await startAuthenticated(tester);

      await tester.tap(find.text('Holidays'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // O cabeçalho de navegação de mês deve estar visível (ícones de chevron)
      expect(find.byTooltip('Mês anterior'), findsOneWidget);
      expect(find.byTooltip('Próximo mês'), findsOneWidget);
    });

    testWidgets('exibe loading durante o carregamento do calendário', (tester) async {
      await startAuthenticated(tester);

      await tester.tap(find.text('Holidays'));
      // Pump sem esperar o futuro completar — deve mostrar o indicador
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // CircularProgressIndicator aparece enquanto carrega
      expect(find.byType(CircularProgressIndicator), findsAny);
    });

    testWidgets('exibe mensagem de erro e botão retry quando API falha', (tester) async {
      await startAuthenticated(tester, statusCode: 500);

      await tester.tap(find.text('Holidays'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Após erro, deve aparecer um botão para tentar novamente
      expect(find.text('Tentar novamente'), findsOneWidget);
    });
  });
}
