import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organizagrana/features/auth/presentation/pages/login_page.dart';
import 'package:organizagrana/l10n/app_localizations.dart';

Future<String?> _pumpAndLogin(
  WidgetTester tester, {
  required String emailInput,
  String password = 'senha123',
}) async {
  String? capturedEmail;

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LoginPage(
        onLogin: ({required String email, required String password}) async {
          capturedEmail = email;
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), emailInput);
  await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), password);
  await tester.tap(find.text('Login'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  return capturedEmail;
}

void main() {
  group('LoginPage — normalização do e-mail', () {
    testWidgets('concatena @mail.com quando o usuário digita só o login',
        (tester) async {
      final email = await _pumpAndLogin(tester, emailInput: 'alexandre');
      expect(email, 'alexandre@mail.com');
    });

    testWidgets('mantém o valor quando já termina com @mail.com', (tester) async {
      final email = await _pumpAndLogin(tester, emailInput: 'alexandre@mail.com');
      expect(email, 'alexandre@mail.com');
    });

    testWidgets('domínio @mail.com é detectado sem diferenciar maiúsculas',
        (tester) async {
      final email = await _pumpAndLogin(tester, emailInput: 'Bob@Mail.Com');
      expect(email, 'Bob@Mail.Com');
    });

    testWidgets('remove espaços ao redor antes de concatenar', (tester) async {
      final email = await _pumpAndLogin(tester, emailInput: '  alexandre  ');
      expect(email, 'alexandre@mail.com');
    });

    testWidgets('campo vazio bloqueia o submit (onLogin não é chamado)',
        (tester) async {
      final email = await _pumpAndLogin(tester, emailInput: '');
      expect(email, isNull);
      expect(find.text('Informe seu e-mail'), findsOneWidget);
    });
  });
}
