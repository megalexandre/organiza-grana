import 'package:flutter/material.dart';
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

    Future<void> startAuthenticatedWithSave(WidgetTester tester) async {
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
        'POST /api/bordero': http.Response(
          encode(savedBorderoBody),
          201,
          headers: {'content-type': 'application/json'},
        ),
      });
      await pumpAuthenticated(tester, client, token);
    }

    // Adiciona um recebível via dialog e aguarda o cálculo retornar.
    // Deve ser chamado após confirmar parâmetros.
    Future<void> addItem(WidgetTester tester) async {
      await tester.tap(find.text('Recebível'));
      await tester.pumpAndSettle();

      // Dialog aberto: 3 TextFormFields — Valor, Data de vencimento, Dias em espera
      await tester.enterText(find.byType(TextFormField).at(0), '1000');
      await tester.enterText(find.byType(TextFormField).at(1), '27/08/2026');

      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('navega para Borderô e exibe o formulário inicial', (tester) async {
      await startAuthenticated(tester);

      await tester.tap(find.text('Borderô'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

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

      expect(find.text('Recebível'), findsOneWidget);
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

    testWidgets('botão Salvar aparece após calcular resultado', (tester) async {
      await startAuthenticatedWithSave(tester);

      await tester.tap(find.text('Borderô'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Preenche taxa e confirma
      await tester.enterText(find.byType(TextFormField).at(1), '2,5');
      await tester.tap(find.text('Confirmar e adicionar recebíveis'));
      await tester.pump();

      await addItem(tester);

      expect(find.text('Salvar'), findsOneWidget);
    });

    testWidgets('salvar borderô exibe snackbar e muda botão para Salvo', (tester) async {
      await startAuthenticatedWithSave(tester);

      await tester.tap(find.text('Borderô'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextFormField).at(1), '2,5');
      await tester.tap(find.text('Confirmar e adicionar recebíveis'));
      await tester.pump();

      await addItem(tester);

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Borderô salvo com sucesso!'), findsOneWidget);
      // Tela limpa — volta ao formulário inicial
      expect(find.text('Confirmar e adicionar recebíveis'), findsOneWidget);
    });
  });
}
