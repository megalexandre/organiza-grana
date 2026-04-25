import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens(String accessToken, {String? refreshToken}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await preferences.setString(_refreshTokenKey, refreshToken);
    } else {
      await preferences.remove(_refreshTokenKey);
    }
  }

  Future<String?> readAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_refreshTokenKey);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
  }
}