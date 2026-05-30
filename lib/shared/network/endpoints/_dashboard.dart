part of '../api_endpoints.dart';

class _Dashboard {
  const _Dashboard();

  static const String _path = '${ApiEndpoints._base}/dashboard';

  String get receivablesByStatus => '$_path/receivables_by_status';
  String get summary => '$_path/summary';
}
