import 'package:organizagrana/features/auth/domain/auth_failure.dart';
import 'package:organizagrana/features/auth/domain/login_attempt.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';
import 'package:organizagrana/shared/network/api_endpoints.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

abstract class AuthApiClient {
  Future<Map<String, dynamic>> login(LoginAttempt attempt);
  Future<Map<String, dynamic>> refresh(String refreshToken);
  Future<Map<String, dynamic>> getMe();
}

class AuthApiClientException implements Exception {
  final AuthFailureType type;

  const AuthApiClientException(this.type);

  String get message => switch (type) {
        AuthFailureType.invalidCredentials => 'Credenciais invalidas.',
        AuthFailureType.sessionExpired =>
          'Sessao expirada. Faca login novamente.',
        AuthFailureType.network => 'Falha de rede ao conectar no servidor.',
        AuthFailureType.server => 'Falha no servidor.',
        AuthFailureType.invalidResponse => 'Resposta invalida da API.',
        _ => 'Erro desconhecido.',
      };
}

class HttpAuthApiClient implements AuthApiClient {
  final HttpApiClient _httpClient;
  final AccessTokenProvider _accessTokenProvider;

  HttpAuthApiClient(
    this._accessTokenProvider, {
    HttpApiClient? httpClient,
  }) : _httpClient = httpClient ?? HttpApiClient();

  @override
  Future<Map<String, dynamic>> login(LoginAttempt attempt) {
    return _call(
      () => _httpClient.postJson(
        Uri.parse(ApiEndpoints.auth.login),
        {'email': attempt.email, 'password': attempt.password},
      ),
      unauthorizedType: AuthFailureType.invalidCredentials,
    );
  }

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken) {
    return _call(
      () => _httpClient.postJson(
        Uri.parse(ApiEndpoints.auth.refresh),
        {'refresh_token': refreshToken},
      ),
      unauthorizedType: AuthFailureType.sessionExpired,
    );
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    final accessToken = await _accessTokenProvider.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthApiClientException(AuthFailureType.sessionExpired);
    }

    return _call(
      () => _httpClient.getJson(
        Uri.parse(ApiEndpoints.user.me),
        bearerToken: accessToken,
      ),
      unauthorizedType: AuthFailureType.sessionExpired,
    );
  }

  Future<Map<String, dynamic>> _call(
    Future<Map<String, dynamic>> Function() fn, {
    required AuthFailureType unauthorizedType,
  }) async {
    try {
      return await fn();
    } on ApiException catch (e) {
      throw AuthApiClientException(_mapFailure(e.type, unauthorizedType));
    }
  }

  AuthFailureType _mapFailure(
    ApiFailureType type,
    AuthFailureType unauthorizedType,
  ) =>
      switch (type) {
        ApiFailureType.network => AuthFailureType.network,
        ApiFailureType.unauthorized => unauthorizedType,
        ApiFailureType.server => AuthFailureType.server,
        ApiFailureType.invalidResponse => AuthFailureType.invalidResponse,
      };
}
