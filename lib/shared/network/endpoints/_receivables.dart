part of '../api_endpoints.dart';

class _Receivables {
  const _Receivables();

  static const String _path = '${ApiEndpoints._base}/receivables';

  String get create => _path;
  String get list => _path;

  String byId(String id) => '$_path/$id';
  String update(String id) => '$_path/$id';
}
