part 'endpoints/_auth.dart';
part 'endpoints/_bordero.dart';
part 'endpoints/_holidays.dart';
part 'endpoints/_receivables.dart';
part 'endpoints/_user.dart';

class ApiEndpoints {
  static const _base = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sandbox.calculajuros.online/api',
  );

  static const auth = _Auth();
  static const user = _User();
  static const receivables = _Receivables();
  static const bordero = _Bordero();
  static const holidays = _Holidays();
}
