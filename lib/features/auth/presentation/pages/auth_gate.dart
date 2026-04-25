import 'package:organizagrana/features/auth/data/auth_service.dart';
import 'package:organizagrana/features/auth/data/auth_storage.dart';
import 'package:organizagrana/features/auth/domain/login_attempt.dart';
import 'package:organizagrana/features/auth/presentation/pages/login_page.dart';
import 'package:organizagrana/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, AuthService? authService})
      : _authService = authService;

  final AuthService? _authService;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthStorage _storage = AuthStorage();
  late final AuthService _authService =
      widget._authService ?? AuthService(_storage);

  bool? _authenticated;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final isAuthenticated = await _authService.isAuthenticated();
    if (!mounted) return;
    final email = isAuthenticated ? await _authService.currentUserEmail() : null;
    if (!mounted) return;

    setState(() {
      _authenticated = isAuthenticated;
      _userEmail = email;
    });
  }

  Future<void> _handleLogin({
    required String email,
    required String password,
  }) async {
    final attempt = LoginAttempt(email: email, password: password);
    final result = await _authService.login(attempt);
    if (!mounted) return;

    if (!result.isSuccess) {
      throw Exception(result.failure?.message ?? 'Falha no login.');
    }

    final currentEmail = await _authService.currentUserEmail();
    if (!mounted) return;

    setState(() {
      _authenticated = true;
      _userEmail = currentEmail;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;

    setState(() {
      _authenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticated == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_authenticated!) {
      return DashboardPage(onLogout: _handleLogout, userEmail: _userEmail);
    }

    return LoginPage(onLogin: _handleLogin);
  }
}