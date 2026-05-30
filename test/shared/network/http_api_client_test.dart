import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:organizagrana/shared/network/http_api_client.dart';

final _uri = Uri.parse('https://api.test/resource');

void main() {
  group('HttpApiClient — token resolution', () {
    test('usa o bearerToken explícito no header', () async {
      String? sentAuth;
      final client = HttpApiClient(
        httpClient: MockClient((req) async {
          sentAuth = req.headers['Authorization'];
          return http.Response('{}', 200);
        }),
      );

      await client.getJson(_uri, bearerToken: 'tok-1');
      expect(sentAuth, 'Bearer tok-1');
    });

    test('resolve o token via bearerTokenProvider', () async {
      String? sentAuth;
      final client = HttpApiClient(
        httpClient: MockClient((req) async {
          sentAuth = req.headers['Authorization'];
          return http.Response('{}', 200);
        }),
        bearerTokenProvider: () async => 'provided',
      );

      await client.getJson(_uri);
      expect(sentAuth, 'Bearer provided');
    });

    test('lança unauthorized quando o provider devolve token vazio', () async {
      final client = HttpApiClient(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
        bearerTokenProvider: () async => '',
      );

      expect(
        () => client.getJson(_uri),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiFailureType.unauthorized)),
      );
    });
  });

  group('HttpApiClient — retry em 401', () {
    test('renova o token e repete a requisição após 401', () async {
      var calls = 0;
      final tokens = <String?>[];
      final client = HttpApiClient(
        httpClient: MockClient((req) async {
          calls++;
          tokens.add(req.headers['Authorization']);
          if (calls == 1) return http.Response('{"error":"expired"}', 401);
          return http.Response('{"ok":true}', 200);
        }),
        bearerTokenProvider: () async => 'old-token',
        tokenRefresher: () async => 'new-token',
      );

      final result = await client.getJson(_uri);

      expect(calls, 2);
      expect(tokens, ['Bearer old-token', 'Bearer new-token']);
      expect(result['ok'], isTrue);
    });

    test('não repete quando não há refresher e propaga unauthorized', () async {
      var calls = 0;
      final client = HttpApiClient(
        httpClient: MockClient((_) async {
          calls++;
          return http.Response('{"error":"expired"}', 401);
        }),
        bearerTokenProvider: () async => 'old-token',
      );

      await expectLater(
        () => client.getJson(_uri),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiFailureType.unauthorized)),
      );
      expect(calls, 1);
    });

    test('o retry em 401 funciona em postJson', () async {
      var calls = 0;
      final client = HttpApiClient(
        httpClient: MockClient((req) async {
          calls++;
          if (calls == 1) return http.Response('{}', 401);
          return http.Response('{"saved":1}', 200);
        }),
        bearerTokenProvider: () async => 'old',
        tokenRefresher: () async => 'new',
      );

      final result = await client.postJson(_uri, {'a': 1});
      expect(calls, 2);
      expect(result['saved'], 1);
    });
  });

  group('HttpApiClient — parsing e status', () {
    test('getJson exige objeto JSON', () async {
      final client = HttpApiClient(
        httpClient: MockClient((_) async => http.Response('[1,2,3]', 200)),
      );

      expect(
        () => client.getJson(_uri),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiFailureType.invalidResponse)),
      );
    });

    test('getJsonList filtra apenas mapas', () async {
      final client = HttpApiClient(
        httpClient: MockClient(
          (_) async => http.Response(jsonEncode([{'id': 1}, 'lixo', {'id': 2}]), 200),
        ),
      );

      final list = await client.getJsonList(_uri);
      expect(list, hasLength(2));
      expect(list.map((e) => e['id']), [1, 2]);
    });

    test('status 5xx vira ApiFailureType.server', () async {
      final client = HttpApiClient(
        httpClient: MockClient((_) async => http.Response('{}', 500)),
      );

      expect(
        () => client.getJson(_uri),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiFailureType.server)),
      );
    });

    test('falha de transporte vira ApiFailureType.network', () async {
      final client = HttpApiClient(
        httpClient: MockClient((_) async => throw Exception('socket down')),
      );

      expect(
        () => client.getJson(_uri),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiFailureType.network)),
      );
    });

    test('deleteVoid valida status sem exigir corpo', () async {
      final client = HttpApiClient(
        httpClient: MockClient((_) async => http.Response('', 204)),
      );

      await expectLater(client.deleteVoid(_uri, bearerToken: 't'), completes);
    });
  });
}
