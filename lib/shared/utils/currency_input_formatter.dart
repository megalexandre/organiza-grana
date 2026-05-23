import 'package:flutter/services.dart';

/// Formata o campo como moeda brasileira em tempo real.
/// O usuário digita apenas dígitos; os dois últimos são centavos.
/// Ex: "1" → "0,01" | "123" → "1,23" | "123456" → "1.234,56"
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cents = int.parse(digits);
    final formatted = _format(cents);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _format(int cents) {
    final intPart = cents ~/ 100;
    final decPart = cents % 100;

    final intFormatted = _formatThousands(intPart);
    return '$intFormatted,${decPart.toString().padLeft(2, '0')}';
  }

  static String _formatThousands(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// Converte o texto formatado de volta para centavos.
  static int toCents(String formatted) {
    final digits = formatted.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 0;
    return int.parse(digits);
  }
}
