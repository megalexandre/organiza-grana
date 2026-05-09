part of '../api_endpoints.dart';

class _Holidays {
  const _Holidays();

  static const String _path = '${ApiEndpoints._base}/holidays';

  Uri calendar(int year, int month) => Uri.parse(_path).replace(
        queryParameters: {'year': '$year', 'month': '$month'},
      );

  Uri get createOverride => Uri.parse(_path);
  Uri updateOverride(String id) => Uri.parse('$_path/$id');
  Uri deleteOverride(String id) => Uri.parse('$_path/$id');
}
