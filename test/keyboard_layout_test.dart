import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Verifica que o padrão de padding via MediaQuery.viewInsetsOf (usado em
// add_receivable_dialog, bordero_page, etc.) responde corretamente ao
// aparecimento e desaparecimento do teclado virtual.

Widget _buildWithKeyboard(
  Widget child, {
  double keyboardHeight = 0,
  Size screenSize = const Size(390, 844),
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: screenSize,
      viewInsets: EdgeInsets.only(bottom: keyboardHeight),
    ),
    child: MaterialApp(
      home: Scaffold(resizeToAvoidBottomInset: false, body: child),
    ),
  );
}

// Widget que replica o padrão de padding usado nas dialogs/sheets do app.
class _KeyboardAwarePadding extends StatelessWidget {
  const _KeyboardAwarePadding({required this.basePadding, required this.child});

  final double basePadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: basePadding + keyboardPadding),
      child: child,
    );
  }
}

void main() {
  group('keyboard-aware padding', () {
    testWidgets('sem teclado, usa apenas o padding base', (tester) async {
      await tester.pumpWidget(
        _buildWithKeyboard(
          const _KeyboardAwarePadding(
            basePadding: 24,
            child: SizedBox(height: 100),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding.resolve(TextDirection.ltr).bottom, 24.0);
    });

    testWidgets('com teclado, soma padding base + altura do teclado',
        (tester) async {
      const keyboardHeight = 300.0;

      await tester.pumpWidget(
        _buildWithKeyboard(
          const _KeyboardAwarePadding(
            basePadding: 24,
            child: SizedBox(height: 100),
          ),
          keyboardHeight: keyboardHeight,
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(
        padding.padding.resolve(TextDirection.ltr).bottom,
        24.0 + keyboardHeight,
      );
    });

    testWidgets('ao fechar teclado, padding volta ao valor base',
        (tester) async {
      // Teclado aparece.
      await tester.pumpWidget(
        _buildWithKeyboard(
          const _KeyboardAwarePadding(
            basePadding: 24,
            child: SizedBox(height: 100),
          ),
          keyboardHeight: 300,
        ),
      );

      // Teclado some.
      await tester.pumpWidget(
        _buildWithKeyboard(
          const _KeyboardAwarePadding(
            basePadding: 24,
            child: SizedBox(height: 100),
          ),
        ),
      );
      await tester.pump();

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding.resolve(TextDirection.ltr).bottom, 24.0);
    });
  });

  group('bottom sheet com ConstrainedBox', () {
    testWidgets('não causa overflow com conteúdo menor que maxHeight',
        (tester) async {
      const screenHeight = 844.0;

      await tester.pumpWidget(
        _buildWithKeyboard(
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: screenHeight * 0.9),
            child: const SizedBox(height: 400),
          ),
        ),
      );

      // Se houvesse overflow, o framework lançaria um erro de teste.
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'com teclado ativo, conteúdo permanece dentro dos limites visíveis',
        (tester) async {
      const screenHeight = 844.0;
      const keyboardHeight = 300.0;

      await tester.pumpWidget(
        _buildWithKeyboard(
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: screenHeight * 0.9),
              child: const SizedBox(height: 400),
            ),
          ),
          keyboardHeight: keyboardHeight,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
