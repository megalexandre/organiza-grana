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
    http.Response response;

    try {
      response = await _httpClient.get(
        uri,
        headers: bearerToken != null
            ? {'Authorization': 'Bearer $bearerToken'}
            : const {},
      );
    } catch (_) {
      throw const ApiException(ApiFailureType.network);
    }

    return _parseResponse(response);
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

    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw const ApiException(ApiFailureType.unauthorized);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException(ApiFailureType.server);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(ApiFailureType.invalidResponse);
    }

    return decoded;
  }
}
