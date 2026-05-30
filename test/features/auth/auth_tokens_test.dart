import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:organizagrana/features/auth/domain/auth_tokens.dart';

/// Monta um JWT falso (não assinado) a partir de um payload arbitrário.
String _jwt(Map<String, dynamic> payload) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final header = seg({'alg': 'HS256', 'typ': 'JWT'});
  return '$header.${seg(payload)}.fakesig';
}

int _unix(DateTime dt) => dt.millisecondsSinceEpoch ~/ 1000;

void main() {
  group('AuthTokens.fromJwt', () {
    test('extrai sub, email, iat e exp do payload', () {
      final iat = DateTime.utc(2026, 1, 1, 12);
      final exp = DateTime.utc(2026, 1, 1, 13);
      final token = _jwt({
        'sub': 'user-42',
        'email': 'alex@mail.com',
        'iat': _unix(iat),
        'exp': _unix(exp),
      });

      final tokens = AuthTokens.fromJwt(token);

      expect(tokens.accessToken, token);
      expect(tokens.subject, 'user-42');
      expect(tokens.email, 'alex@mail.com');
      expect(tokens.issuedAt?.toUtc(), iat);
      expect(tokens.expiresAt?.toUtc(), exp);
    });

    test('usa user_id quando sub está ausente', () {
      final token = _jwt({'user_id': 'uid-7'});
      expect(AuthTokens.fromJwt(token).subject, 'uid-7');
    });

    test('lança FormatException quando não tem 3 partes', () {
      expect(() => AuthTokens.fromJwt('a.b'), throwsFormatException);
    });

    test('lança FormatException quando o payload não é um objeto JSON', () {
      final bad = 'h.${base64Url.encode(utf8.encode('[1,2,3]')).replaceAll('=', '')}.s';
      expect(() => AuthTokens.fromJwt(bad), throwsFormatException);
    });

    test('propaga refreshToken e tokenType informados', () {
      final token = _jwt({'sub': 'x'});
      final tokens = AuthTokens.fromJwt(token, refreshToken: 'r1', tokenType: 'Custom');
      expect(tokens.refreshToken, 'r1');
      expect(tokens.tokenType, 'Custom');
      expect(tokens.authorizationHeader, 'Custom $token');
    });
  });

  group('AuthTokens.isExpired', () {
    test('é false quando exp está no futuro', () {
      final token = _jwt({'exp': _unix(DateTime.now().add(const Duration(hours: 1)))});
      expect(AuthTokens.fromJwt(token).isExpired, isFalse);
    });

    test('é true quando exp está no passado', () {
      final token = _jwt({'exp': _unix(DateTime.now().subtract(const Duration(hours: 1)))});
      expect(AuthTokens.fromJwt(token).isExpired, isTrue);
    });

    test('é false quando não há exp', () {
      final token = _jwt({'sub': 'x'});
      expect(AuthTokens.fromJwt(token).isExpired, isFalse);
    });
  });

  group('AuthTokens.fromResponse', () {
    test('aceita a chave "token"', () {
      final token = _jwt({'sub': 'x'});
      final tokens = AuthTokens.fromResponse({'token': token});
      expect(tokens.accessToken, token);
    });

    test('aceita "access_token", "accessToken" e "jwt"', () {
      final token = _jwt({'sub': 'x'});
      for (final key in ['access_token', 'accessToken', 'jwt']) {
        expect(AuthTokens.fromResponse({key: token}).accessToken, token);
      }
    });

    test('lança FormatException quando não há JWT válido', () {
      expect(() => AuthTokens.fromResponse({}), throwsFormatException);
      expect(() => AuthTokens.fromResponse({'token': ''}), throwsFormatException);
      expect(() => AuthTokens.fromResponse({'token': 123}), throwsFormatException);
    });

    test('captura refresh_token e token_type quando presentes', () {
      final token = _jwt({'sub': 'x'});
      final tokens = AuthTokens.fromResponse({
        'token': token,
        'refresh_token': 'r-99',
        'token_type': 'Bearer',
      });
      expect(tokens.refreshToken, 'r-99');
      expect(tokens.tokenType, 'Bearer');
    });

    test('expires_at explícito sobrepõe o exp do JWT', () {
      final jwtExp = DateTime.now().add(const Duration(hours: 1));
      final explicit = DateTime.utc(2030, 6, 1, 8);
      final token = _jwt({'sub': 'x', 'exp': _unix(jwtExp)});

      final tokens = AuthTokens.fromResponse({
        'token': token,
        'expires_at': explicit.toIso8601String(),
      });

      expect(tokens.expiresAt?.toUtc(), explicit);
    });
  });
}
