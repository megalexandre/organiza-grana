import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_draft.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_sort.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_update.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_page_result.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
import 'package:organizagrana/shared/network/api_endpoints.dart';
import 'package:organizagrana/shared/network/authenticated_api_client.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

abstract class ReceivablesApiClient {
  Future<ReceivablesPageResult> listPage({
    required int page,
    required int perPage,
    bool withDiscarded = false,
    ReceivableSortField sortBy = ReceivableSortField.dueDate,
    ReceivableSortDirection sortDirection = ReceivableSortDirection.desc,
  });
  Future<Receivable> getById(String id);
  Future<void> create(ReceivableDraft draft);
  Future<void> update(String id, ReceivableUpdate update);
  Future<void> changeStatus(String id, ReceivableStatus status);
  Future<void> delete(String id);
}

class ReceivablesApiClientException implements Exception {
  const ReceivablesApiClientException(this.type);

  final ReceivableFailureType type;
}

class HttpReceivablesApiClient with AuthenticatedApiClient implements ReceivablesApiClient {
  HttpReceivablesApiClient(AccessTokenProvider provider, {HttpApiClient? httpClient})
      : httpClient = httpClient ?? HttpApiClient(bearerTokenProvider: provider.readAccessToken);

  @override
  final HttpApiClient httpClient;

  @override
  Future<ReceivablesPageResult> listPage({
    required int page,
    required int perPage,
    bool withDiscarded = false,
    ReceivableSortField sortBy = ReceivableSortField.dueDate,
    ReceivableSortDirection sortDirection = ReceivableSortDirection.desc,
  }) {
    final uri = Uri.parse(ApiEndpoints.receivables.list).replace(queryParameters: {
      'page': '$page',
      'per_page': '$perPage',
      'with_discarded': '$withDiscarded',
      'sort_by': sortBy.toApiValue(),
      'sort_direction': sortDirection.toApiValue(),
    });
    return guarded(
      () => httpClient.getJson(uri).then(ReceivablesPageResult.fromJson),
      (type) => ReceivablesApiClientException(_toFailureType(type)),
    );
  }

  @override
  Future<Receivable> getById(String id) => guarded(
        () async {
          final response = await httpClient.getJson(
            Uri.parse(ApiEndpoints.receivables.byId(id)),
          );
          final raw = response['receivable'] ?? response;
          if (raw is! Map<String, dynamic>) {
            throw const ReceivablesApiClientException(ReceivableFailureType.invalidResponse);
          }
          return Receivable.fromJson(raw);
        },
        (type) => ReceivablesApiClientException(_toFailureType(type)),
      );

  @override
  Future<void> create(ReceivableDraft draft) => guarded(
        () => httpClient.postJson(Uri.parse(ApiEndpoints.receivables.create), draft.toJson()),
        (type) => ReceivablesApiClientException(_toFailureType(type)),
      );

  @override
  Future<void> update(String id, ReceivableUpdate update) => guarded(
        () => httpClient.putJson(Uri.parse(ApiEndpoints.receivables.update(id)), update.toJson()),
        (type) => ReceivablesApiClientException(_toFailureType(type)),
      );

  @override
  Future<void> changeStatus(String id, ReceivableStatus status) => guarded(
        () => httpClient.patchJson(
          Uri.parse(ApiEndpoints.receivables.changeStatus(id)),
          {'status': status.toJson()},
        ),
        (type) => ReceivablesApiClientException(_toFailureType(type)),
      );

  @override
  Future<void> delete(String id) => guarded(
        () => httpClient.deleteVoid(Uri.parse(ApiEndpoints.receivables.delete(id))),
        (type) => ReceivablesApiClientException(_toFailureType(type)),
      );

  ReceivableFailureType _toFailureType(ApiFailureType type) => switch (type) {
        ApiFailureType.network => ReceivableFailureType.network,
        ApiFailureType.unauthorized => ReceivableFailureType.unauthorized,
        ApiFailureType.server => ReceivableFailureType.server,
        ApiFailureType.invalidResponse => ReceivableFailureType.invalidResponse,
      };
}
