part of '../api_endpoints.dart';

class _Auth {
  const _Auth();

  static const String _path = '${ApiEndpoints._base}/auth';
  final String login = '$_path/login';
  final String refresh = '$_path/refresh';
}
