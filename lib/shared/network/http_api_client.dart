import 'dart:convert';

import 'package:http/http.dart' as http;

enum ApiFailureType { network, unauthorized, server, invalidResponse }

class ApiException implements Exception {
  final ApiFailureType type;
  const ApiException(this.type);
}

class HttpApiClient {
  final http.Client _httpClient;

  HttpApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> getJson(
    Uri uri, {
    String? bearerToken,
  }) async {
    final response = await _get(uri, bearerToken: bearerToken);
    return _parseMapResponse(response);
  }

  Future<List<Map<String, dynamic>>> getJsonList(
    Uri uri, {
    String? bearerToken,
  }) async {
    final response = await _get(uri, bearerToken: bearerToken);
    return _parseListResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    http.Response response;

    try {
      response = await _httpClient.post(
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

    return _parseMapResponse(response);
  }

  Future<http.Response> _get(
    Uri uri, {
    String? bearerToken,
  }) async {
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
    if (response.statusCode == 401) {
      throw const ApiException(ApiFailureType.unauthorized);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException(ApiFailureType.server);
    }
  }
}
