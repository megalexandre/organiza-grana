part of '../api_endpoints.dart';

class _Receivables {
  const _Receivables();

  static const String _path = '${ApiEndpoints._base}/receivables';

  String get create => _path;
  String get list => _path;
  String get export => '$_path/export';

  String get audit => '$_path/audit';

  String byId(String id) => '$_path/$id';
  String update(String id) => '$_path/$id';
  String delete(String id) => '$_path/$id';
  String changeStatus(String id) => '$_path/$id/change_status';
}
