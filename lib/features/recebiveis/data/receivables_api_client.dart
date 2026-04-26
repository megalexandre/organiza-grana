import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_draft.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_page_result.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_pagination.dart';
import 'package:organizagrana/shared/network/api_enpoints.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

abstract class ReceivablesApiClient {
  Future<ReceivablesPageResult> listPage({
    required int page,
    required int perPage,
    bool withDiscarded = false,
  });
  Future<void> create(ReceivableDraft draft);
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
  }) async {
    final token = await _readToken();
    final baseUri = Uri.parse(ApiEndpoints.receivables.list);
    final uri = baseUri.replace(queryParameters: {
      'page': '$page',
      'per_page': '$perPage',
      'with_discarded': '$withDiscarded',
    });

    try {
      final response = await _httpClient.getJson(uri, bearerToken: token);
      final items = _extractListFromMap(response);
      return ReceivablesPageResult(
        items: items.map(Receivable.fromJson).toList(),
        pagination: _extractPagination(response),
      );
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
        {
          'value': draft.value,
          'receipt_date': _formatDate(draft.receiptDate),
          'status': draft.status.toJson(),
        },
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

  List<Map<String, dynamic>> _extractListFromMap(Map<String, dynamic> response) {
    final candidates = [
      response['data'],
      response['items'],
      response['receivables'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const [];
  }

  ReceivablesPagination _extractPagination(Map<String, dynamic> response) {
    final rawPagination = response['pagination'];
    if (rawPagination is Map<String, dynamic>) {
      return ReceivablesPagination.fromJson(rawPagination);
    }

    return const ReceivablesPagination(
      currentPage: 1,
      perPage: 10,
      totalPages: 1,
      totalCount: 0,
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}'
      '-${date.day.toString().padLeft(2, '0')}';

  ReceivableFailureType _mapFailure(ApiFailureType type) => switch (type) {
        ApiFailureType.network => ReceivableFailureType.network,
        ApiFailureType.unauthorized => ReceivableFailureType.unauthorized,
        ApiFailureType.server => ReceivableFailureType.server,
        ApiFailureType.invalidResponse => ReceivableFailureType.invalidResponse,
      };
}