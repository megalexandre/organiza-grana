import 'dart:convert';

import 'package:organizagrana/features/auth/domain/auth_failure.dart';
import 'package:organizagrana/features/auth/domain/login_attempt.dart';
import 'package:organizagrana/shared/network/api_enpoints.dart';
import 'package:http/http.dart' as http;

abstract class AuthApiClient {
  Future<Map<String, dynamic>> login(LoginAttempt attempt);
  Future<Map<String, dynamic>> refresh(String refreshToken);
  Future<Map<String, dynamic>> getMe(String accessToken);
}

class AuthApiClientException implements Exception {
  final AuthFailureType type;

  const AuthApiClientException(this.type);

  String get message => switch (type) {
        AuthFailureType.invalidCredentials => 'Credenciais invalidas.',
        AuthFailureType.sessionExpired => 'Sessao expirada. Faca login novamente.',
        AuthFailureType.network => 'Falha de rede ao conectar no servidor.',
        AuthFailureType.server => 'Falha no servidor.',
        AuthFailureType.invalidResponse => 'Resposta invalida da API.',
        _ => 'Erro desconhecido.',
      };
}

class HttpAuthApiClient implements AuthApiClient {
  final http.Client _httpClient;

  HttpAuthApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  Future<Map<String, dynamic>> login(LoginAttempt attempt) {
    return _postJson(
      Uri.parse(ApiEndpoints.auth.login),
      {'email': attempt.email, 'password': attempt.password},

    );
  }

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken) {
    return _postJson(
      Uri.parse(ApiEndpoints.auth.refresh),
      {'refresh_token': refreshToken},
      unauthorizedType: AuthFailureType.sessionExpired,
    );
  }

  @override
  Future<Map<String, dynamic>> getMe(String accessToken) {
    return _getJson(
      Uri.parse(ApiEndpoints.user.me),
      accessToken: accessToken,
    );
  }

  Future<Map<String, dynamic>> _getJson(
    Uri uri, {
    required String accessToken,
  }) async {
    http.Response response;

    try {
      response = await _httpClient.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (_) {
      throw const AuthApiClientException(AuthFailureType.network);
    }

    if (response.statusCode == 401) {
      throw const AuthApiClientException(AuthFailureType.sessionExpired);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AuthApiClientException(AuthFailureType.server);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const AuthApiClientException(AuthFailureType.invalidResponse);
    }

    return decoded;
  }

  Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, dynamic> body, {
    AuthFailureType unauthorizedType = AuthFailureType.invalidCredentials,
  }) async {
    http.Response response;

    try {
      response = await _httpClient.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const AuthApiClientException(AuthFailureType.network);
    }

    if (response.statusCode == 401) {
      throw AuthApiClientException(unauthorizedType);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AuthApiClientException(AuthFailureType.server);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const AuthApiClientException(AuthFailureType.invalidResponse);
    }

    return decoded;
  }
}
