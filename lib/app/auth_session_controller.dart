import 'package:flutter/foundation.dart';
import 'package:organizagrana/features/auth/data/auth_service.dart';
import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/auth/domain/login_attempt.dart';
import 'package:organizagrana/features/auth/domain/user_profile.dart';
import 'package:organizagrana/shared/layout/user_display_profile.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController({AuthService? authService})
      : _authService = authService ?? AuthService(AuthStorage());

  final AuthService _authService;

  bool _initialized = false;
  bool _authenticated = false;
  String? _userEmail;
  UserProfile? _userProfile;

  bool get initialized => _initialized;
  bool get isAuthenticated => _authenticated;

  UserDisplayProfile? get displayProfile {
    final email = _userProfile?.email ?? _userEmail;
    if (email == null) return null;
    return UserDisplayProfile(email: email, avatarUrl: _userProfile?.photoUrl);
  }

  Future<void> initialize() async {
    final isAuthenticated = await _authService.isAuthenticated();

    _initialized = true;
    _authenticated = isAuthenticated;
    _userEmail = isAuthenticated ? await _authService.currentUserEmail() : null;
    notifyListeners();

    if (_authenticated) _fetchProfile();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final result = await _authService.login(LoginAttempt(email: email, password: password));

    if (!result.isSuccess) {
      throw Exception(result.failure?.message ?? 'Falha no login.');
    }

    _authenticated = true;
    _userEmail = await _authService.currentUserEmail();
    notifyListeners();

    _fetchProfile();
  }

  Future<void> logout() async {
    await _authService.logout();
    _authenticated = false;
    _userEmail = null;
    _userProfile = null;
    notifyListeners();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await _authService.getMe();
      _userProfile = profile;
      notifyListeners();
    } catch (_) {}
  }
}