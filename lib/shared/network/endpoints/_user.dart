part of '../api_endpoints.dart';

class _User {
  const _User();

  static const String _path = '${ApiEndpoints._base}/users';
  final String register = '$_path/register';
  final String me = '$_path/me';
}
