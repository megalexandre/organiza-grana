class LoginAttempt {
  final String email;
  final String password;

  const LoginAttempt({
    required this.email,
    required this.password,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty;
}
