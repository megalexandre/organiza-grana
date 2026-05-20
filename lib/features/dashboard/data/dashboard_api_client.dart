import 'package:organizagrana/features/dashboard/domain/dashboard_failure.dart';
import 'package:organizagrana/features/dashboard/domain/receivable_status_count.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
import 'package:organizagrana/shared/network/api_endpoints.dart';
import 'package:organizagrana/shared/network/authenticated_api_client.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

abstract class DashboardApiClient {
  Future<List<ReceivableStatusCount>> fetchReceivablesByStatus();
}

class DashboardApiClientException implements Exception {
  const DashboardApiClientException(this.type);

  final DashboardFailureType type;
}

class HttpDashboardApiClient with AuthenticatedApiClient implements DashboardApiClient {
  HttpDashboardApiClient(AccessTokenProvider provider, {HttpApiClient? httpClient})
      : httpClient = httpClient ?? HttpApiClient(bearerTokenProvider: provider.readAccessToken);

  @override
  final HttpApiClient httpClient;

  @override
  Future<List<ReceivableStatusCount>> fetchReceivablesByStatus() => guarded(
        () async {
          final response = await httpClient.getJson(
            Uri.parse(ApiEndpoints.dashboard.receivablesByStatus),
          );
          final data = response['data'] as List<dynamic>;
          return data
              .cast<Map<String, dynamic>>()
              .map(ReceivableStatusCount.fromJson)
              .toList();
        },
        (type) => DashboardApiClientException(_toFailureType(type)),
      );

  DashboardFailureType _toFailureType(ApiFailureType type) => switch (type) {
        ApiFailureType.network => DashboardFailureType.network,
        ApiFailureType.unauthorized => DashboardFailureType.unauthorized,
        ApiFailureType.server => DashboardFailureType.server,
        ApiFailureType.invalidResponse => DashboardFailureType.invalidResponse,
      };
}
