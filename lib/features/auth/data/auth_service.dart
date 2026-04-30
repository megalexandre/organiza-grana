import 'package:organizagrana/features/auth/data/auth_api_client.dart';
import 'package:organizagrana/features/auth/data/auth_access_token_provider.dart';
import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/auth/domain/auth_tokens.dart';
import 'package:organizagrana/features/auth/domain/auth_failure.dart';
import 'package:organizagrana/features/auth/domain/auth_result.dart';
import 'package:organizagrana/features/auth/domain/login_attempt.dart';
import 'package:organizagrana/features/auth/domain/user_profile.dart';

class AuthService {
  final AuthStorage _storage;
  final AuthApiClient _apiClient;

  AuthService(this._storage, {AuthApiClient? apiClient})
    : _apiClient = apiClient
      ?? HttpAuthApiClient(AuthStorageAccessTokenProvider(_storage));

  Future<bool> isAuthenticated() async {
    final accessToken = await _storage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    try {
      final access = AuthTokens.fromJwt(accessToken);
      if (!access.isExpired) {
        return true;
      }
    } on FormatException {
      await _storage.clear();
      return false;
    }

    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _storage.clear();
      return false;
    }

    final result = await _refreshSession(refreshToken);
    return result.isSuccess;
  }

  Future<AuthResult> login(LoginAttempt attempt) async {
    if (!attempt.isValid) {
      return const AuthResult.failure(
        AuthFailure(
          type: AuthFailureType.invalidInput,
          message: 'Informe e-mail e senha.',
        ),
      );
    }

    try {
      final response = await _apiClient.login(attempt);
      final tokens = AuthTokens.fromResponse(response);
      await _persistTokens(tokens);
      return const AuthResult.success();
    } on AuthApiClientException catch (error) {
      return AuthResult.failure(
        AuthFailure(type: error.type, message: error.message),
      );
    } on FormatException {
      return const AuthResult.failure(
        AuthFailure(
          type: AuthFailureType.invalidResponse,
          message: 'Resposta de autenticacao invalida.',
        ),
      );
    }
  }

  Future<void> logout() async {
    await _storage.clear();
  }

  Future<AuthResult> _refreshSession(String refreshToken) async {
    try {
      final response = await _apiClient.refresh(refreshToken);
      final tokens = AuthTokens.fromResponse(response);
      await _persistTokens(tokens);
      return const AuthResult.success();
    } on AuthApiClientException catch (error) {
      await _storage.clear();
      return AuthResult.failure(
        AuthFailure(type: error.type, message: error.message),
      );
    } on FormatException {
      await _storage.clear();
      return const AuthResult.failure(
        AuthFailure(
          type: AuthFailureType.invalidResponse,
          message: 'Resposta de refresh invalida.',
        ),
      );
    }
  }

  Future<void> _persistTokens(AuthTokens tokens) async {
    await _storage.saveTokens(
      tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    final result = await _refreshSession(refreshToken);
    if (!result.isSuccess) return null;
    return _storage.readAccessToken();
  }

  Future<UserProfile> getMe() async {
    final response = await _apiClient.getMe();
    return UserProfile.fromJson(response);
  }

  Future<String?> currentUserEmail() async {
    final accessToken = await _storage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;
    try {
      final tokens = AuthTokens.fromJwt(accessToken);
      return tokens.email;
    } on FormatException {
      return null;
    }
  }
}