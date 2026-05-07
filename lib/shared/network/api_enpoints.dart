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
}

class _Receivables {
  const _Receivables();

  static const String path = '${ApiEndpoints._base}/receivables';
  final String create = path;
  final String list = path;
  String byId(String id) => '$path/$id';
  String update(String id) => '$path/$id';
}

class _Bordero {
  const _Bordero();

  static const String path = '${ApiEndpoints._base}/bordero';
  final String calculate = '$path/calculate';
}

class _Holidays {
  const _Holidays();

  static const String _path = '${ApiEndpoints._base}/holidays';

  Uri calendar(int year, int month) => Uri.parse('$_path?year=$year&month=$month');

  Uri get createOverride => Uri.parse(_path);
  Uri updateOverride(String id) => Uri.parse('$_path/$id');
  Uri deleteOverride(String id) => Uri.parse('$_path/$id');
}

class _Auth {
  const _Auth();

  static const String path = '${ApiEndpoints._base}/auth';
  final String login = '$path/login';
  final String refresh = '$path/refresh';
}

class _User {
  const _User();

  static const String path = '${ApiEndpoints._base}/users';
  final String register = '$path/register';
  final String me = '$path/me';
}
