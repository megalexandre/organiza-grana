import 'package:organizagrana/features/bordero/domain/bordero_failure.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result.dart';
import 'package:organizagrana/features/bordero/domain/bordero_sort.dart';
import 'package:organizagrana/features/bordero/domain/borderos_page_result.dart';
import 'package:organizagrana/features/bordero/domain/saved_bordero.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
import 'package:organizagrana/shared/network/api_endpoints.dart';
import 'package:organizagrana/shared/network/authenticated_api_client.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

abstract class BorderoApiClient {
  Future<BorderosPageResult> listPage({
    required int page,
    required int perPage,
    BorderoSortField sortBy,
    BorderoSortDirection sortDirection,
  });
  Future<BorderoResult> calculate(BorderoInput input);
  Future<SavedBordero> getById(String id);
  Future<SavedBordero> save(BorderoInput input);
  Future<SavedBordero> update(String id, BorderoInput input);
}

class BorderoApiClientException implements Exception {
  const BorderoApiClientException(this.type);

  final BorderoFailureType type;
}

class HttpBorderoApiClient with AuthenticatedApiClient implements BorderoApiClient {
  HttpBorderoApiClient(AccessTokenProvider provider, {HttpApiClient? httpClient})
      : httpClient = httpClient ?? HttpApiClient(bearerTokenProvider: provider.readAccessToken);

  @override
  final HttpApiClient httpClient;

  @override
  Future<BorderosPageResult> listPage({
    required int page,
    required int perPage,
    BorderoSortField sortBy = BorderoSortField.changeDate,
    BorderoSortDirection sortDirection = BorderoSortDirection.desc,
  }) {
    final uri = Uri.parse(ApiEndpoints.bordero.list).replace(queryParameters: {
      'page': '$page',
      'per_page': '$perPage',
      'sort_by': sortBy.toApiValue(),
      'sort_direction': sortDirection.toApiValue(),
    });
    return guarded(
      () => httpClient.getJson(uri).then(BorderosPageResult.fromJson),
      (type) => BorderoApiClientException(_toFailureType(type)),
    );
  }

  @override
  Future<SavedBordero> getById(String id) => guarded(
        () async {
          final response = await httpClient.getJson(
            Uri.parse(ApiEndpoints.bordero.byId(id)),
          );
          final raw = response['bordero'] ?? response;
          if (raw is! Map<String, dynamic>) {
            throw const BorderoApiClientException(BorderoFailureType.invalidResponse);
          }
          return SavedBordero.fromJson(raw);
        },
        (type) => BorderoApiClientException(_toFailureType(type)),
      );

  @override
  Future<BorderoResult> calculate(BorderoInput input) => guarded(
        () => httpClient
            .postJson(Uri.parse(ApiEndpoints.bordero.calculate), input.toJson())
            .then(BorderoResult.fromJson),
        (type) => BorderoApiClientException(_toFailureType(type)),
      );

  @override
  Future<SavedBordero> save(BorderoInput input) => guarded(
        () => httpClient
            .postJson(Uri.parse(ApiEndpoints.bordero.save), input.toJson())
            .then(SavedBordero.fromJson),
        (type) => BorderoApiClientException(_toFailureType(type)),
      );

  @override
  Future<SavedBordero> update(String id, BorderoInput input) => guarded(
        () => httpClient
            .putJson(Uri.parse(ApiEndpoints.bordero.update(id)), input.toJson())
            .then(SavedBordero.fromJson),
        (type) => BorderoApiClientException(_toFailureType(type)),
      );

  BorderoFailureType _toFailureType(ApiFailureType type) => switch (type) {
        ApiFailureType.network => BorderoFailureType.network,
        ApiFailureType.unauthorized => BorderoFailureType.unauthorized,
        ApiFailureType.server => BorderoFailureType.server,
        ApiFailureType.invalidResponse => BorderoFailureType.invalidResponse,
      };
}
