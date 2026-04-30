import 'package:organizagrana/features/bordero/domain/bordero_failure.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
import 'package:organizagrana/shared/network/api_enpoints.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

abstract class BorderoApiClient {
  Future<BorderoResult> calculate(BorderoInput input);
}

class BorderoApiClientException implements Exception {
  const BorderoApiClientException(this.type);

  final BorderoFailureType type;
}

class HttpBorderoApiClient implements BorderoApiClient {
  HttpBorderoApiClient(this._accessTokenProvider, {HttpApiClient? httpClient})
      : _httpClient = httpClient ?? HttpApiClient();

  final AccessTokenProvider _accessTokenProvider;
  final HttpApiClient _httpClient;

  @override
  Future<BorderoResult> calculate(BorderoInput input) async {
    final token = await _readToken();

    try {
      final response = await _httpClient.postJson(
        Uri.parse(ApiEndpoints.bordero.calculate),
        input.toJson(),
        bearerToken: token,
      );
      return BorderoResult.fromJson(response);
    } on ApiException catch (e) {
      throw BorderoApiClientException(_mapFailure(e.type));
    }
  }

  Future<String> _readToken() async {
    final token = await _accessTokenProvider.readAccessToken();
    if (token == null || token.isEmpty) {
      throw const BorderoApiClientException(BorderoFailureType.unauthorized);
    }
    return token;
  }

  BorderoFailureType _mapFailure(ApiFailureType type) => switch (type) {
        ApiFailureType.network => BorderoFailureType.network,
        ApiFailureType.unauthorized => BorderoFailureType.unauthorized,
        ApiFailureType.server => BorderoFailureType.server,
        ApiFailureType.invalidResponse => BorderoFailureType.invalidResponse,
      };
}
