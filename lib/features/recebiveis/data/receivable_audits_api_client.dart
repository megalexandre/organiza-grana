import 'package:organizagrana/features/recebiveis/domain/receivable_audit.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
import 'package:organizagrana/shared/network/api_endpoints.dart';
import 'package:organizagrana/shared/network/authenticated_api_client.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

abstract class ReceivableAuditsApiClient {
  Future<ReceivableAuditPageResult> listPage({required int page, required int perPage});
}

class HttpReceivableAuditsApiClient
    with AuthenticatedApiClient
    implements ReceivableAuditsApiClient {
  HttpReceivableAuditsApiClient(AccessTokenProvider provider, {HttpApiClient? httpClient})
      : httpClient = httpClient ?? HttpApiClient(bearerTokenProvider: provider.readAccessToken);

  @override
  final HttpApiClient httpClient;

  @override
  Future<ReceivableAuditPageResult> listPage({required int page, required int perPage}) {
    final uri = Uri.parse(ApiEndpoints.receivables.audit).replace(
      queryParameters: {'page': '$page', 'per_page': '$perPage'},
    );
    return guarded(
      () => httpClient.getJson(uri).then(ReceivableAuditPageResult.fromJson),
      (type) => Exception('audit fetch failed: $type'),
    );
  }
}
