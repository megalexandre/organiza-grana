import 'package:flutter/foundation.dart';

/// Logger central, leve. Em release não imprime nada (usa [debugPrint], que é
/// suprimido fora de debug). Centraliza o tratamento de erros que antes eram
/// silenciosamente engolidos em blocos `catch (_) {}`.
class AppLogger {
  const AppLogger._();

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARN', message, error, stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  static void _log(String level, String message, Object? error, StackTrace? stackTrace) {
    if (!kDebugMode) return;
    final buffer = StringBuffer('[$level] $message');
    if (error != null) buffer.write(' — $error');
    debugPrint(buffer.toString());
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }
}
