import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:organizagrana/features/auth/data/auth_api_client.dart';
import 'package:organizagrana/features/auth/data/auth_service.dart';
import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/auth/domain/auth_failure.dart';
import 'package:organizagrana/features/auth/domain/login_attempt.dart';

String _jwt(Map<String, dynamic> payload) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${seg({'alg': 'HS256'})}.${seg(payload)}.sig';
}

int _unix(DateTime dt) => dt.millisecondsSinceEpoch ~/ 1000;

String _validToken({String email = 'alex@mail.com'}) => _jwt({
      'sub': 'user-1',
      'email': email,
      'exp': _unix(DateTime.now().add(const Duration(hours: 1))),
    });

String _expiredToken() => _jwt({
      'sub': 'user-1',
      'exp': _unix(DateTime.now().subtract(const Duration(hours: 1))),
    });

/// AuthStorage em memória — desacopla os testes do backend de persistência.
class _InMemoryStorage extends AuthStorage {
  String? access;
  String? refresh;
  int clearCount = 0;

  @override
  Future<void> saveTokens(String accessToken, {String? refreshToken}) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    clearCount++;
  }
}

class _FakeApiClient implements AuthApiClient {
  _FakeApiClient({this.onLogin, this.onRefresh});

  Future<Map<String, dynamic>> Function()? onLogin;
  Future<Map<String, dynamic>> Function()? onRefresh;

  int loginCalls = 0;
  int refreshCalls = 0;

  @override
  Future<Map<String, dynamic>> login(LoginAttempt attempt) {
    loginCalls++;
    return onLogin!();
  }

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken) {
    refreshCalls++;
    return onRefresh!();
  }

  @override
  Future<Map<String, dynamic>> getMe() async => {};
}

void main() {
  group('AuthService.login', () {
    test('credenciais vazias falham sem chamar a API', () async {
      final api = _FakeApiClient();
      final service = AuthService(_InMemoryStorage(), apiClient: api);

      final result = await service.login(const LoginAttempt(email: '', password: ''));

      expect(result.isSuccess, isFalse);
      expect(result.failure?.type, AuthFailureType.invalidInput);
      expect(api.loginCalls, 0);
    });

    test('sucesso persiste tokens', () async {
      final storage = _InMemoryStorage();
      final token = _validToken();
      final api = _FakeApiClient(
        onLogin: () async => {'access_token': token, 'refresh_token': 'r-1'},
      );
      final service = AuthService(storage, apiClient: api);

      final result = await service.login(
        const LoginAttempt(email: 'alex@mail.com', password: 'x'),
      );

      expect(result.isSuccess, isTrue);
      expect(storage.access, token);
      expect(storage.refresh, 'r-1');
    });

    test('erro da API vira falha tipada', () async {
      final api = _FakeApiClient(
        onLogin: () async =>
            throw const AuthApiClientException(AuthFailureType.invalidCredentials),
      );
      final service = AuthService(_InMemoryStorage(), apiClient: api);

      final result = await service.login(
        const LoginAttempt(email: 'a@mail.com', password: 'x'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.failure?.type, AuthFailureType.invalidCredentials);
    });

    test('resposta sem JWT vira falha invalidResponse', () async {
      final api = _FakeApiClient(onLogin: () async => {'foo': 'bar'});
      final service = AuthService(_InMemoryStorage(), apiClient: api);

      final result = await service.login(
        const LoginAttempt(email: 'a@mail.com', password: 'x'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.failure?.type, AuthFailureType.invalidResponse);
    });
  });

  group('AuthService.isAuthenticated', () {
    test('false quando não há access token', () async {
      final service = AuthService(_InMemoryStorage(), apiClient: _FakeApiClient());
      expect(await service.isAuthenticated(), isFalse);
    });

    test('true quando o access token é válido e não expirou', () async {
      final storage = _InMemoryStorage()..access = _validToken();
      final service = AuthService(storage, apiClient: _FakeApiClient());
      expect(await service.isAuthenticated(), isTrue);
    });

    test('token expirado com refresh válido renova e retorna true', () async {
      final storage = _InMemoryStorage()
        ..access = _expiredToken()
        ..refresh = 'r-1';
      final api = _FakeApiClient(
        onRefresh: () async => {'access_token': _validToken(), 'refresh_token': 'r-2'},
      );
      final service = AuthService(storage, apiClient: api);

      expect(await service.isAuthenticated(), isTrue);
      expect(api.refreshCalls, 1);
      expect(storage.refresh, 'r-2');
    });

    test('token expirado sem refresh limpa storage e retorna false', () async {
      final storage = _InMemoryStorage()..access = _expiredToken();
      final service = AuthService(storage, apiClient: _FakeApiClient());

      expect(await service.isAuthenticated(), isFalse);
      expect(storage.clearCount, greaterThan(0));
    });

    test('token malformado limpa storage e retorna false', () async {
      final storage = _InMemoryStorage()..access = 'not-a-jwt';
      final service = AuthService(storage, apiClient: _FakeApiClient());

      expect(await service.isAuthenticated(), isFalse);
      expect(storage.clearCount, greaterThan(0));
    });
  });

  group('AuthService.refreshAccessToken', () {
    test('retorna null quando não há refresh token', () async {
      final service = AuthService(_InMemoryStorage(), apiClient: _FakeApiClient());
      expect(await service.refreshAccessToken(), isNull);
    });

    test('retorna o novo access token em caso de sucesso', () async {
      final newToken = _validToken();
      final storage = _InMemoryStorage()..refresh = 'r-1';
      final api = _FakeApiClient(
        onRefresh: () async => {'access_token': newToken, 'refresh_token': 'r-2'},
      );
      final service = AuthService(storage, apiClient: api);

      expect(await service.refreshAccessToken(), newToken);
    });

    test('falha no refresh limpa storage e retorna null', () async {
      final storage = _InMemoryStorage()..refresh = 'r-1';
      final api = _FakeApiClient(
        onRefresh: () async =>
            throw const AuthApiClientException(AuthFailureType.sessionExpired),
      );
      final service = AuthService(storage, apiClient: api);

      expect(await service.refreshAccessToken(), isNull);
      expect(storage.clearCount, greaterThan(0));
    });

    test('chamadas concorrentes reutilizam um único refresh (sem stampede)',
        () async {
      final storage = _InMemoryStorage()..refresh = 'r-1';
      final api = _FakeApiClient(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return {'access_token': _validToken(), 'refresh_token': 'r-2'};
        },
      );
      final service = AuthService(storage, apiClient: api);

      // Dispara 3 refreshes em paralelo antes do primeiro completar.
      await Future.wait([
        service.refreshAccessToken(),
        service.refreshAccessToken(),
        service.refreshAccessToken(),
      ]);

      expect(api.refreshCalls, 1);
    });

    test('um novo refresh é possível após o anterior concluir', () async {
      final storage = _InMemoryStorage()..refresh = 'r-1';
      final api = _FakeApiClient(
        onRefresh: () async => {'access_token': _validToken(), 'refresh_token': 'r-2'},
      );
      final service = AuthService(storage, apiClient: api);

      await service.refreshAccessToken();
      await service.refreshAccessToken();

      expect(api.refreshCalls, 2);
    });
  });

  group('AuthService.currentUserEmail', () {
    test('extrai o email do access token', () async {
      final storage = _InMemoryStorage()..access = _validToken(email: 'bob@mail.com');
      final service = AuthService(storage, apiClient: _FakeApiClient());
      expect(await service.currentUserEmail(), 'bob@mail.com');
    });

    test('retorna null para token malformado', () async {
      final storage = _InMemoryStorage()..access = 'garbage';
      final service = AuthService(storage, apiClient: _FakeApiClient());
      expect(await service.currentUserEmail(), isNull);
    });
  });
}
