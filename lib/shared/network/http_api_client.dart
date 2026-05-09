import 'dart:convert';

import 'package:http/http.dart' as http;

enum ApiFailureType { network, unauthorized, server, invalidResponse }

class ApiException implements Exception {
  final ApiFailureType type;
  const ApiException(this.type);
}

typedef TokenRefresher = Future<String?> Function();
typedef BearerTokenProvider = Future<String?> Function();

class HttpApiClient {
  HttpApiClient({
    http.Client? httpClient,
    TokenRefresher? tokenRefresher,
    BearerTokenProvider? bearerTokenProvider,
  })  : _httpClient = httpClient ?? http.Client(),
        _tokenRefresher = tokenRefresher,
        _bearerTokenProvider = bearerTokenProvider;

  final http.Client _httpClient;
  final TokenRefresher? _tokenRefresher;
  final BearerTokenProvider? _bearerTokenProvider;

  Future<String?> _resolveToken(String? override) async {
    if (override != null) return override;
    if (_bearerTokenProvider == null) return null;
    final token = await _bearerTokenProvider();
    if (token == null || token.isEmpty) throw const ApiException(ApiFailureType.unauthorized);
    return token;
  }

  Future<Map<String, dynamic>> getJson(Uri uri, {String? bearerToken}) async {
    final token = await _resolveToken(bearerToken);
    var response = await _get(uri, bearerToken: token);
    if (response.statusCode == 401 && _tokenRefresher != null) {
      final newToken = await _tokenRefresher();
      if (newToken != null) response = await _get(uri, bearerToken: newToken);
    }
    return _parseMapResponse(response);
  }

  Future<List<Map<String, dynamic>>> getJsonList(Uri uri, {String? bearerToken}) async {
    final token = await _resolveToken(bearerToken);
    var response = await _get(uri, bearerToken: token);
    if (response.statusCode == 401 && _tokenRefresher != null) {
      final newToken = await _tokenRefresher();
      if (newToken != null) response = await _get(uri, bearerToken: newToken);
    }
    return _parseListResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    final token = await _resolveToken(bearerToken);
    var response = await _post(uri, body, bearerToken: token);
    if (response.statusCode == 401 && _tokenRefresher != null) {
      final newToken = await _tokenRefresher();
      if (newToken != null) response = await _post(uri, body, bearerToken: newToken);
    }
    return _parseMapResponse(response);
  }

  Future<Map<String, dynamic>> putJson(
    Uri uri,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    final token = await _resolveToken(bearerToken);
    var response = await _put(uri, body, bearerToken: token);
    if (response.statusCode == 401 && _tokenRefresher != null) {
      final newToken = await _tokenRefresher();
      if (newToken != null) response = await _put(uri, body, bearerToken: newToken);
    }
    return _parseMapResponse(response);
  }

  Future<Map<String, dynamic>> patchJson(
    Uri uri,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    final token = await _resolveToken(bearerToken);
    var response = await _patch(uri, body, bearerToken: token);
    if (response.statusCode == 401 && _tokenRefresher != null) {
      final newToken = await _tokenRefresher();
      if (newToken != null) response = await _patch(uri, body, bearerToken: newToken);
    }
    return _parseMapResponse(response);
  }

  Future<void> deleteVoid(Uri uri, {String? bearerToken}) async {
    final token = await _resolveToken(bearerToken);
    var response = await _delete(uri, bearerToken: token);
    if (response.statusCode == 401 && _tokenRefresher != null) {
      final newToken = await _tokenRefresher();
      if (newToken != null) response = await _delete(uri, bearerToken: newToken);
    }
    _validateStatus(response);
  }

  Future<http.Response> _get(Uri uri, {String? bearerToken}) async {
    try {
      return await _httpClient.get(
        uri,
        headers: bearerToken != null
            ? {'Authorization': 'Bearer $bearerToken'}
            : const {},
      );
    } catch (_) {
      throw const ApiException(ApiFailureType.network);
    }
  }

  Future<http.Response> _post(
    Uri uri,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    try {
      return await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const ApiException(ApiFailureType.network);
    }
  }

  Future<http.Response> _put(
    Uri uri,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    try {
      return await _httpClient.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const ApiException(ApiFailureType.network);
    }
  }

  Future<http.Response> _patch(
    Uri uri,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    try {
      return await _httpClient.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const ApiException(ApiFailureType.network);
    }
  }

  Future<http.Response> _delete(Uri uri, {String? bearerToken}) async {
    try {
      return await _httpClient.delete(
        uri,
        headers: bearerToken != null
            ? {'Authorization': 'Bearer $bearerToken'}
            : const {},
      );
    } catch (_) {
      throw const ApiException(ApiFailureType.network);
    }
  }

  Map<String, dynamic> _parseMapResponse(http.Response response) {
    _validateStatus(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(ApiFailureType.invalidResponse);
    }
    return decoded;
  }

  List<Map<String, dynamic>> _parseListResponse(http.Response response) {
    _validateStatus(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ApiException(ApiFailureType.invalidResponse);
    }
    return decoded.whereType<Map<String, dynamic>>().toList();
  }

  void _validateStatus(http.Response response) {
    if (response.statusCode == 401) throw const ApiException(ApiFailureType.unauthorized);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException(ApiFailureType.server);
    }
  }
}
