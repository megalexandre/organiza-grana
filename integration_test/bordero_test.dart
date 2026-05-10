import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Borderô', () {
    Future<void> startAuthenticated(WidgetTester tester) async {
      final token = fakeJwt();
      final client = buildMockClient({
        'GET /api/users/me': http.Response(
          encode(getMeBody),
          200,
          headers: {'content-type': 'application/json'},
        ),
        'POST /api/bordero/calculate': http.Response(
          encode(borderoResultBody),
          200,
          headers: {'content-type': 'application/json'},
        ),
      });
      await pumpAuthenticated(tester, client, token);
    }

    testWidgets('navega para Borderô e exibe o formulário inicial', (tester) async {
      await startAuthenticated(tester);

      await tester.tap(find.text('Borderô'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // O formulário inicial tem campo de data e botão de confirmar
      expect(find.text('Data da troca'), findsOneWidget);
      expect(find.text('Confirmar e adicionar recebíveis'), findsOneWidget);
    });

    testWidgets('confirma parâmetros e exibe FAB para adicionar recebível', (tester) async {
      await startAuthenticated(tester);

      await tester.tap(find.text('Borderô'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Confirmar e adicionar recebíveis'));
      await tester.pump();

      // Após confirmar, o FAB 'Recebível' deve aparecer
      expect(find.text('Recebível'), findsOneWidget);
      // O formulário inicial some
      expect(find.text('Confirmar e adicionar recebíveis'), findsNothing);
    });

    testWidgets('botão Editar volta ao formulário de parâmetros', (tester) async {
      await startAuthenticated(tester);

      await tester.tap(find.text('Borderô'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Confirmar e adicionar recebíveis'));
      await tester.pump();

      await tester.tap(find.text('Editar'));
      await tester.pump();

      expect(find.text('Confirmar e adicionar recebíveis'), findsOneWidget);
    });
  });
}
