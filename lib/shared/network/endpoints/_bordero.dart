part of '../api_endpoints.dart';

class _Bordero {
  const _Bordero();

  static const String _path = '${ApiEndpoints._base}/bordero';
  final String save = _path;
  final String list = _path;
  String byId(String id) => '$_path/$id';
  String update(String id) => '$_path/$id';
}
