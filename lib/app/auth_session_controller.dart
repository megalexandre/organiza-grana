import 'package:flutter/foundation.dart';
import 'package:organizagrana/features/auth/data/auth_service.dart';
import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/auth/domain/login_attempt.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController({AuthService? authService})
      : _authService = authService ?? AuthService(AuthStorage());

  final AuthService _authService;

  bool _initialized = false;
  bool _authenticated = false;
  String? _userEmail;

  bool get initialized => _initialized;
  bool get isAuthenticated => _authenticated;
  String? get userEmail => _userEmail;

  Future<void> initialize() async {
    final isAuthenticated = await _authService.isAuthenticated();
    final email = isAuthenticated ? await _authService.currentUserEmail() : null;

    _initialized = true;
    _authenticated = isAuthenticated;
    _userEmail = email;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final attempt = LoginAttempt(email: email, password: password);
    final result = await _authService.login(attempt);

    if (!result.isSuccess) {
      throw Exception(result.failure?.message ?? 'Falha no login.');
    }

    _authenticated = true;
    _userEmail = await _authService.currentUserEmail();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _authenticated = false;
    _userEmail = null;
    notifyListeners();
  }
}