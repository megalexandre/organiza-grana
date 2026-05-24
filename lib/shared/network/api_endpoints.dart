part 'endpoints/_auth.dart';
part 'endpoints/_bordero.dart';
part 'endpoints/_dashboard.dart';
part 'endpoints/_holidays.dart';
part 'endpoints/_receivables.dart';
part 'endpoints/_user.dart';

class ApiEndpoints {
  static const _base = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const auth = _Auth();
  static const user = _User();
  static const receivables = _Receivables();
  static const bordero = _Bordero();
  static const holidays = _Holidays();
  static const dashboard = _Dashboard();
}
