import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_draft.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_sort.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_update.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_page_result.dart';
import 'package:organizagrana/shared/network/api_endpoints.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
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
}

class ReceivablesApiClientException implements Exception {
  const ReceivablesApiClientException(this.type);

  final ReceivableFailureType type;
}

class HttpReceivablesApiClient implements ReceivablesApiClient {
  HttpReceivablesApiClient(this._accessTokenProvider, {HttpApiClient? httpClient})
      : _httpClient = httpClient ?? HttpApiClient();

  final AccessTokenProvider _accessTokenProvider;
  final HttpApiClient _httpClient;

  @override
  Future<ReceivablesPageResult> listPage({
    required int page,
    required int perPage,
    bool withDiscarded = false,
    ReceivableSortField sortBy = ReceivableSortField.dueDate,
    ReceivableSortDirection sortDirection = ReceivableSortDirection.desc,
  }) async {
    final token = await _readToken();
    final baseUri = Uri.parse(ApiEndpoints.receivables.list);
    final uri = baseUri.replace(queryParameters: {
      'page': '$page',
      'per_page': '$perPage',
      'with_discarded': '$withDiscarded',
      'sort_by': sortBy.toApiValue(),
      'sort_direction': sortDirection.toApiValue(),
    });

    try {
      final response = await _httpClient.getJson(uri, bearerToken: token);
      return ReceivablesPageResult.fromJson(response);
    } on ApiException catch (e) {
      throw ReceivablesApiClientException(_mapFailure(e.type));
    }
  }

  @override
  Future<Receivable> getById(String id) async {
    final token = await _readToken();
    try {
      final response = await _httpClient.getJson(
        Uri.parse(ApiEndpoints.receivables.byId(id)),
        bearerToken: token,
      );
      final raw = response['receivable'] ?? response;
      if (raw is! Map<String, dynamic>) {
        throw const ReceivablesApiClientException(ReceivableFailureType.invalidResponse);
      }
      return Receivable.fromJson(raw);
    } on ApiException catch (e) {
      throw ReceivablesApiClientException(_mapFailure(e.type));
    }
  }

  @override
  Future<void> create(ReceivableDraft draft) async {
    final token = await _readToken();

    try {
      await _httpClient.postJson(
        Uri.parse(ApiEndpoints.receivables.create),
        draft.toJson(),
        bearerToken: token,
      );
    } on ApiException catch (e) {
      throw ReceivablesApiClientException(_mapFailure(e.type));
    }
  }

  @override
  Future<void> update(String id, ReceivableUpdate update) async {
    final token = await _readToken();

    try {
      await _httpClient.putJson(
        Uri.parse(ApiEndpoints.receivables.update(id)),
        update.toJson(),
        bearerToken: token,
      );
    } on ApiException catch (e) {
      throw ReceivablesApiClientException(_mapFailure(e.type));
    }
  }

  Future<String> _readToken() async {
    final token = await _accessTokenProvider.readAccessToken();
    if (token == null || token.isEmpty) {
      throw const ReceivablesApiClientException(ReceivableFailureType.unauthorized);
    }
    return token;
  }

  ReceivableFailureType _mapFailure(ApiFailureType type) => switch (type) {
        ApiFailureType.network => ReceivableFailureType.network,
        ApiFailureType.unauthorized => ReceivableFailureType.unauthorized,
        ApiFailureType.server => ReceivableFailureType.server,
        ApiFailureType.invalidResponse => ReceivableFailureType.invalidResponse,
      };
}