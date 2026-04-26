import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/shared/network/access_token_provider.dart';

class AuthStorageAccessTokenProvider implements AccessTokenProvider {
  AuthStorageAccessTokenProvider(this._storage);

  final AuthStorage _storage;

  @override
  Future<String?> readAccessToken() {
    return _storage.readAccessToken();
  }
}